require "test_helper"

class GolfRangesControllerTest < ActionDispatch::IntegrationTest
  setup do
    GolfPracticeRange.destroy_all

    @higashiosaka = GolfPracticeRange.create!(
      name: "東大阪テスト練習場",
      city: "東大阪市",
      address: "大阪府東大阪市テスト町1-1"
    )

    @yao = GolfPracticeRange.create!(
      name: "八尾テスト練習場",
      city: "八尾市",
      address: "大阪府八尾市テスト町2-2"
    )
  end

  test "一覧ページが正常に表示される" do
    get golf_ranges_url

    assert_response :success
  end

  test "地域を指定すると該当する練習場のみ表示される" do
    get golf_ranges_url, params: { city: "東大阪市" }

    assert_response :success
    assert_select "h2", text: @higashiosaka.name
    assert_select "h2", text: @yao.name, count: 0
  end

  test "地域を指定しない場合はすべて表示される" do
    get golf_ranges_url

    assert_response :success
    assert_select "h2", text: @higashiosaka.name
    assert_select "h2", text: @yao.name
  end

  test "検索結果が0件でもエラーにならない" do
    get golf_ranges_url, params: { city: "存在しない地域" }

    assert_response :success
    assert_select "p", text: /該当する地域の練習場はありません/
  end

  test "リセット用リンクが表示される" do
    get golf_ranges_url, params: { city: "東大阪市" }

    assert_response :success
    assert_select "a[href='#{golf_ranges_path}']", text: "リセット"
  end

  test "最安ボール単価が安い順に並ぶ" do
    add_price(@higashiosaka, 12)
    add_price(@yao, 8)

    get golf_ranges_url, params: { sort: "price_asc" }

    assert_response :success
    assert_equal [ @yao.name, @higashiosaka.name ],
                 displayed_range_names
  end

  test "複数料金がある場合は最安値を基準に並ぶ" do
    add_price(@higashiosaka, 12, day_type: :weekday)
    add_price(@higashiosaka, 7, day_type: :weekend)
    add_price(@yao, 9)

    get golf_ranges_url, params: { sort: "price_asc" }

    assert_response :success
    assert_equal [ @higashiosaka.name, @yao.name ],
                 displayed_range_names
  end

  test "料金未登録の施設は最後に表示される" do
    add_price(@yao, 10)

    get golf_ranges_url, params: { sort: "price_asc" }

    assert_response :success
    assert_equal [ @yao.name, @higashiosaka.name ],
                 displayed_range_names
  end

  test "地域検索と料金順の並び替えを併用できる" do
    another_range = GolfPracticeRange.create!(
      name: "東大阪第二練習場",
      city: "東大阪市",
      address: "大阪府東大阪市テスト町3-3"
    )

    add_price(@higashiosaka, 12)
    add_price(another_range, 8)
    add_price(@yao, 5)

    get golf_ranges_url,
        params: { city: "東大阪市", sort: "price_asc" }

    assert_response :success
    assert_equal [ another_range.name, @higashiosaka.name ],
                 displayed_range_names
  end

  test "同額の場合は名前順で表示される" do
    add_price(@higashiosaka, 10)
    add_price(@yao, 10)

    get golf_ranges_url, params: { sort: "price_asc" }

    assert_response :success
    assert_equal [ @yao.name, @higashiosaka.name ].sort,
                 displayed_range_names
  end

  test "料金未登録の施設も一覧に表示される" do
    get golf_ranges_url

    assert_response :success
    assert_select "h2", text: @higashiosaka.name
    assert_select "p", text: "情報なし"
  end

  test "料金未登録でも詳細ページが正常に表示される" do
    get golf_range_url(@higashiosaka)

    assert_response :success
    assert_select "h1", text: @higashiosaka.name
    assert_select "p", text: /料金情報が登録されていません/
  end

  test "平日料金のみ登録されている場合は休日に情報なしと表示される" do
    @higashiosaka.ball_prices.create!(
      day_type: :weekday,
      price_per_ball: 10
    )

    get golf_range_url(@higashiosaka)

    assert_response :success
    assert_select "h3", text: "平日"
    assert_select "h3", text: "土日祝"
    assert_select "p", text: "情報なし"
    assert_select "td", text: /10円\/球/
  end

  test "平日と休日の料金を区別して表示できる" do
    add_price(@higashiosaka, 8, day_type: :weekday)
    add_price(@higashiosaka, 12, day_type: :weekend)

    get golf_range_url(@higashiosaka)

    assert_response :success
    assert_select "h3", text: "平日"
    assert_select "h3", text: "土日祝"
    assert_select "td", text: "8円/球"
    assert_select "td", text: "12円/球"
  end

  test "階数ごとの料金を表示できる" do
    @higashiosaka.ball_prices.create!(
      day_type: :weekday,
      floor_number: 1,
      price_per_ball: 10
    )

    @higashiosaka.ball_prices.create!(
      day_type: :weekday,
      floor_number: 2,
      price_per_ball: 8
    )

    get golf_range_url(@higashiosaka)

    assert_response :success
    assert_select "td", text: "1階"
    assert_select "td", text: "2階"
    assert_select "td", text: "10円/球"
    assert_select "td", text: "8円/球"
  end

  test "時間帯ごとの料金を表示できる" do
    @higashiosaka.ball_prices.create!(
      day_type: :weekday,
      price_per_ball: 7,
      start_time: "18:00",
      end_time: "22:00"
    )

    get golf_range_url(@higashiosaka)

    assert_response :success
    assert_select "td", text: "18:00〜22:00"
    assert_select "td", text: "7円/球"
  end

  test "終日と全階共通の料金を表示できる" do
    @higashiosaka.ball_prices.create!(
      day_type: :weekday,
      floor_number: nil,
      start_time: nil,
      end_time: nil,
      price_per_ball: 9
    )

    get golf_range_url(@higashiosaka)

    assert_response :success
    assert_select "td", text: "全階共通"
    assert_select "td", text: "終日"
    assert_select "td", text: "9円/球"
  end


  test "公式サイトへのリンクが表示される" do
    @higashiosaka.update!(
      official_website_url: "https://example.com/golf"
    )

    get golf_range_url(@higashiosaka)

    assert_response :success
    assert_select "a[href='https://example.com/golf']",
                  text: "公式サイトを見る"
  end

  test "公式サイトが新しいタブで開く" do
    @higashiosaka.update!(
      official_website_url: "https://example.com/golf"
    )

    get golf_range_url(@higashiosaka)

    assert_response :success
    assert_select "a[href='https://example.com/golf'][target='_blank'][rel='noopener noreferrer']"
  end

  test "公式サイトURLが未登録の場合はリンクを表示しない" do
    @higashiosaka.update!(
      official_website_url: nil
    )

    get golf_range_url(@higashiosaka)

    assert_response :success
    assert_select "a", text: "公式サイトを見る", count: 0
  end

  test "不正な公式サイトURLの場合はリンクを表示しない" do
    @higashiosaka.update!(
      official_website_url: "javascript:alert(1)"
    )

    get golf_range_url(@higashiosaka)

    assert_response :success
    assert_select "a", text: "公式サイトを見る", count: 0
  end


  private

  def add_price(range, price, day_type: :weekday)
    range.ball_prices.create!(
      day_type: day_type,
      price_per_ball: price
    )
  end

  def displayed_range_names
    css_select(".grid h2").map { |element| element.text.strip }
  end
end

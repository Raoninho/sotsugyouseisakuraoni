require "test_helper"

class GolfRangesControllerTest < ActionDispatch::IntegrationTest
  setup do
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
end

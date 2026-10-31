require "test_helper"

class GolfPracticeRangeTest < ActiveSupport::TestCase
  test "必須項目があれば保存できる" do
    range = GolfPracticeRange.new(
      name: "テストゴルフ練習場",
      city: "東大阪市",
      address: "大阪府東大阪市テスト町1-1"
    )

    assert range.valid?
  end

  test "練習場名が未入力の場合は無効" do
    range = valid_range
    range.name = nil

    assert_not range.valid?
    assert_includes range.errors[:name], "can't be blank"
  end

  test "市区町村が未入力の場合は無効" do
    range = valid_range
    range.city = nil

    assert_not range.valid?
    assert_includes range.errors[:city], "can't be blank"
  end

  test "住所が未入力の場合は無効" do
    range = valid_range
    range.address = nil

    assert_not range.valid?
    assert_includes range.errors[:address], "can't be blank"
  end

  test "複数の料金から最安値を取得できる" do
    range = valid_range
    range.save!

    range.ball_prices.create!(
      day_type: :weekday,
      floor_number: 1,
      price_per_ball: 10
    )

    range.ball_prices.create!(
      day_type: :weekday,
      floor_number: 2,
      price_per_ball: 8
    )

    range.ball_prices.create!(
      day_type: :weekend,
      floor_number: 1,
      price_per_ball: 12
    )

    assert_equal BigDecimal("8"), range.minimum_ball_price
  end

  test "時間帯が異なる料金も最安値の対象になる" do
    range = valid_range
    range.save!

    range.ball_prices.create!(
      day_type: :weekday,
      price_per_ball: 10
    )

    range.ball_prices.create!(
      day_type: :weekend,
      price_per_ball: 7,
      start_time: "18:00",
      end_time: "22:00"
    )

    assert_equal BigDecimal("7"), range.minimum_ball_price
  end

  test "料金情報がない場合はnilを返す" do
    range = valid_range
    range.save!

    assert_nil range.minimum_ball_price
  end

  private

  def valid_range
    GolfPracticeRange.new(
      name: "テストゴルフ練習場",
      city: "東大阪市",
      address: "大阪府東大阪市テスト町1-1"
    )
  end
end

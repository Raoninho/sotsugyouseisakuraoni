require "test_helper"

class BallPriceTest < ActiveSupport::TestCase
  setup do
    @range = GolfPracticeRange.create!(
      name: "テスト練習場",
      city: "東大阪市",
      address: "大阪府東大阪市テスト町1-1"
    )
  end

  test "正常な料金を登録できる" do
    price = @range.ball_prices.build(
      day_type: :weekday,
      price_per_ball: 10,
      floor_number: 1
    )

    assert price.valid?
  end

  test "0円の料金は登録できない" do
    price = @range.ball_prices.build(
      day_type: :weekday,
      price_per_ball: 0
    )

    assert_not price.valid?
  end

  test "開始時刻のみでは登録できない" do
    price = @range.ball_prices.build(
      day_type: :weekday,
      price_per_ball: 10,
      start_time: "09:00"
    )

    assert_not price.valid?
  end

  test "正常な時間帯は登録できる" do
    price = @range.ball_prices.build(
      day_type: :weekday,
      price_per_ball: 10,
      start_time: "09:00",
      end_time: "17:00"
    )

    assert price.valid?
  end

  test "終了時刻が開始時刻以前なら登録できない" do
    price = @range.ball_prices.build(
      day_type: :weekday,
      price_per_ball: 10,
      start_time: "17:00",
      end_time: "09:00"
    )

    assert_not price.valid?
  end

  test "休日料金を登録できる" do
    price = @range.ball_prices.build(
      day_type: :weekend,
      price_per_ball: 12.50,
      floor_number: 2
    )

    assert price.valid?
  end

  test "階数が0以下なら登録できない" do
    price = @range.ball_prices.build(
      day_type: :weekday,
      price_per_ball: 10,
      floor_number: 0
    )

    assert_not price.valid?
  end
end

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

  private

  def valid_range
    GolfPracticeRange.new(
      name: "テストゴルフ練習場",
      city: "東大阪市",
      address: "大阪府東大阪市テスト町1-1"
    )
  end
end

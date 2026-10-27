class BallPrice < ApplicationRecord
  belongs_to :golf_practice_range

  enum :day_type, {
    weekday: 0,
    weekend: 1
  }

  validates :price_per_ball,
            presence: true,
            numericality: { greater_than: 0 }

  validates :floor_number,
            numericality: {
              only_integer: true,
              greater_than: 0
            },
            allow_nil: true

  validate :validate_time_range

  private

  def validate_time_range
    return if start_time.nil? && end_time.nil?

    if start_time.nil? || end_time.nil?
      errors.add(:base, "開始時刻と終了時刻は両方入力してください")
    elsif start_time >= end_time
      errors.add(:end_time, "は開始時刻より後にしてください")
    end
  end
end

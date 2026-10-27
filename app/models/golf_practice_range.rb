class GolfPracticeRange < ApplicationRecord
  validates :name, :city, :address, presence: true
  has_many :ball_prices, dependent: :destroy
end

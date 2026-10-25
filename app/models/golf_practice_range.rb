class GolfPracticeRange < ApplicationRecord
  validates :name, :city, :address, presence: true
end

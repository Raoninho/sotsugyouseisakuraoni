class GolfPracticeRange < ApplicationRecord
  validates :name, :city, :address, presence: true

  has_many :ball_prices, dependent: :destroy

  def safe_official_website_url
    url = official_website_url
    return if url.blank?

    uri = URI.parse(url)
    return unless uri.is_a?(URI::HTTP)
    return if uri.host.blank?

    uri.to_s
  rescue URI::InvalidURIError
    nil
  end
end

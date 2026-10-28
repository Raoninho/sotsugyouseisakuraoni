class GolfRangesController < ApplicationController
  def index
    @golf_ranges = GolfPracticeRange
                   .includes(:ball_prices)
                   .with_attached_image
                   .order(:name)

    @golf_ranges = @golf_ranges.where(city: params[:city]) if params[:city].present?
  end

  def show
    @golf_range = GolfPracticeRange
                  .includes(:ball_prices)
                  .find(params[:id])
  end
end

class GolfRangesController < ApplicationController
  def index
    @golf_ranges = GolfPracticeRange
                   .includes(:ball_prices)
                   .with_attached_image
                   .order(:name)
  end

  def show
    @golf_range = GolfPracticeRange
                  .includes(:ball_prices)
                  .find(params[:id])
  end
end

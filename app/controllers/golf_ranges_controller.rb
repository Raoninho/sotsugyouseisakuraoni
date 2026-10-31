
class GolfRangesController < ApplicationController
  def index
    @golf_ranges = GolfPracticeRange
                   .includes(:ball_prices)
                   .with_attached_image

    # 地域検索
    if params[:city].present?
      @golf_ranges = @golf_ranges.where(city: params[:city])
    end

    # 並び替え
    if params[:sort] == "price_asc"
      @golf_ranges = @golf_ranges
                     .select(
                       "golf_practice_ranges.*",
                       "(SELECT MIN(price_per_ball) FROM ball_prices " \
                       "WHERE ball_prices.golf_practice_range_id = golf_practice_ranges.id) AS minimum_price"
                     )
                     .order(
                       Arel.sql(
                         "minimum_price ASC NULLS LAST, " \
                         "golf_practice_ranges.name ASC, " \
                         "golf_practice_ranges.id ASC"
                       )
                     )
    else
      @golf_ranges = @golf_ranges.order(:name, :id)
    end
  end

  def show
    @golf_range = GolfPracticeRange
                  .includes(:ball_prices)
                  .find(params[:id])
  end
end

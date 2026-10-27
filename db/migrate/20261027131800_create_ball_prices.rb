class CreateBallPrices < ActiveRecord::Migration[7.2]
  def change
    create_table :ball_prices do |t|
      t.references :golf_practice_range,
                   null: false,
                   foreign_key: true

      t.integer :day_type, null: false
      t.decimal :price_per_ball,
                precision: 6,
                scale: 2,
                null: false

      t.integer :floor_number
      t.time :start_time
      t.time :end_time

      t.timestamps
    end
  end
end

class CreateGolfPracticeRanges < ActiveRecord::Migration[8.1]
  def change
    create_table :golf_practice_ranges do |t|
      t.string :name, null: false
      t.string :city, null: false
      t.string :address, null: false
      t.text :opening_hours
      t.boolean :parking_available
      t.integer :floor_count
      t.integer :booth_count
      t.integer :yard_length
      t.string :official_website_url
      t.date :last_verified_on
      t.string :source_url

      t.timestamps
    end
  end
end

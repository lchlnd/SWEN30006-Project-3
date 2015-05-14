class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.string :name
      t.references :position, index: true, foreign_key: true
      t.references :postcode, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end

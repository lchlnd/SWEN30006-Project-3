class CreateReadings < ActiveRecord::Migration
  def change
    create_table :readings do |t|
      t.references :location, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end

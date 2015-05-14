class CreatePredictions < ActiveRecord::Migration
  def change
    create_table :predictions do |t|
      t.integer :timeframe
      t.references :position, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end

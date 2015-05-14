class CreatePredictedWindDirections < ActiveRecord::Migration
  def change
    create_table :predicted_wind_directions do |t|

      t.timestamps null: false
    end
  end
end

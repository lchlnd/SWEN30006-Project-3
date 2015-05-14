class CreatePredictedTemperatures < ActiveRecord::Migration
  def change
    create_table :predicted_temperatures do |t|

      t.timestamps null: false
    end
  end
end

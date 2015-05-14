class CreatePredictedWindSpeeds < ActiveRecord::Migration
  def change
    create_table :predicted_wind_speeds do |t|

      t.timestamps null: false
    end
  end
end

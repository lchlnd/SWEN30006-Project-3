class CreatePredictedRainfalls < ActiveRecord::Migration
  def change
    create_table :predicted_rainfalls do |t|

      t.timestamps null: false
    end
  end
end

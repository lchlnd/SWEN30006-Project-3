class CreatePredictedDatapoints < ActiveRecord::Migration
  def change
    create_table :predicted_datapoints do |t|
      t.float :value
      t.string :type
      t.float :probability
      t.references :prediction, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end

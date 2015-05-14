class CreateDatapoints < ActiveRecord::Migration
  def change
    create_table :datapoints do |t|
      t.float :value
      t.string :type
      t.references :reading, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end

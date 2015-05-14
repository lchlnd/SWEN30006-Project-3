class CreateRainfalls < ActiveRecord::Migration
  def change
    create_table :rainfalls do |t|

      t.timestamps null: false
    end
  end
end

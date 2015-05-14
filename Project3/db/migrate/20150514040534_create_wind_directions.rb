class CreateWindDirections < ActiveRecord::Migration
  def change
    create_table :wind_directions do |t|

      t.timestamps null: false
    end
  end
end

class CreateWindSpeeds < ActiveRecord::Migration
  def change
    create_table :wind_speeds do |t|

      t.timestamps null: false
    end
  end
end

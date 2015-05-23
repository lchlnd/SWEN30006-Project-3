class AddTimestampToReading < ActiveRecord::Migration
  def change
    add_column :readings, :timestamp, :datetime
  end
end

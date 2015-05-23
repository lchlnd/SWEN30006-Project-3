class AddSourceIdToReadings < ActiveRecord::Migration
  def change
    add_column :readings, :source_id, :integer
  end
end

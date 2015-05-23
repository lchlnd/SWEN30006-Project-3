class RemoveSourceFromReading < ActiveRecord::Migration
  def change
    remove_column :readings, :source, :string
  end
end

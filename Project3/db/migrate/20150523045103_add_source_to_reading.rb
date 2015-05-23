class AddSourceToReading < ActiveRecord::Migration
  def change
    add_column :readings, :source, :string
  end
end

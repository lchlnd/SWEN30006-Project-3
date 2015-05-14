class CreatePostcodes < ActiveRecord::Migration
  def change
    create_table :postcodes do |t|
      t.integer :code
      t.references :position, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end

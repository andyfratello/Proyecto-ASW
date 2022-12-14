class CreateMicroposts < ActiveRecord::Migration[7.0]

  def change
    create_table :microposts do |t|
      t.text :title
      t.text :url
      t.text :text
      t.integer :user_id
      t.string :creator_name
      t.integer :likes_count, :default => 0
      t.timestamps
    end
  end
end

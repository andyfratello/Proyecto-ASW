class CreateComments < ActiveRecord::Migration[7.0]
  def change
    create_table :comments do |t|
      t.references :micropost, null: false, foreign_key: true
      t.integer :user_id
      t.string :creator_name
      t.text :text
      t.integer :likes_count, :default => 0
      t.integer :parent_id, null: true

      t.timestamps
    end
  end
end

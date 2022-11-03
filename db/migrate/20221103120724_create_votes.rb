class CreateVotes < ActiveRecord::Migration[7.0]
  def change
    create_table :votes do |t|
      t.integer :user_id
      t.integer :micropost_id

      t.timestamps
    end
    add_index :votes, :user_id
    add_index :votes, :micropost_id
  end
end

class CreateComments < ActiveRecord::Migration[7.0]
  def change
    create_table :comments do |t|
      t.integer :userId
      t.integer :upVotes, default: 0
      t.text :text
      t.timestamp :time

      t.timestamps
    end
  end
end

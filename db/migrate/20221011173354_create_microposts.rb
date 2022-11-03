class CreateMicroposts < ActiveRecord::Migration[7.0]

  def change
    create_table :microposts do |t|
      acts_as_votable
      t.text :title
      t.text :url
      t.text :text
      t.integer :user_id

      t.timestamps
    end
  end
end

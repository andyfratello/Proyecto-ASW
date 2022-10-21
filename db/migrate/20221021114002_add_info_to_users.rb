class AddInfoToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :karma, :integer
    add_column :users, :about, :text
  end
end

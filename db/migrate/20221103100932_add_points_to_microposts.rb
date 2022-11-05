class AddPointsToMicroposts < ActiveRecord::Migration[7.0]
  def change
    add_column :microposts, :points, :integer, default: 0
  end
end

class AddTotalPointsToEntries < ActiveRecord::Migration
  def change
    add_column :entries, :total_points, :integer, default: 0
  end
end

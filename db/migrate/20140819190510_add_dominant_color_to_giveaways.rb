class AddDominantColorToGiveaways < ActiveRecord::Migration
  def change
    add_column :giveaways, :dominant_color_image, :string
  end
end

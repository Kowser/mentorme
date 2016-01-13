class AddLinksGoals < ActiveRecord::Migration
  def change
  	add_column :goals, :link, :string
  end
end

class AddQuantityReferences < ActiveRecord::Migration
  def change
  	add_column :steps, :quantity, :integer
  end
end

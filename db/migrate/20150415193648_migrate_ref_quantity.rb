class MigrateRefQuantity < ActiveRecord::Migration
  def change
  	Step.where(template: 'references').update_all(quantity: 3)
  end
end

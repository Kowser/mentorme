class AddDefaultEthnicityOther < ActiveRecord::Migration
  def change
  	change_column :users, :ethnicity_other, :string, default: ''
  end
end

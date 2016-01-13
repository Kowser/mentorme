class AddPackageBackgroundChecks < ActiveRecord::Migration
  def change
  	add_column :background_checks, :package, :string
  end
end

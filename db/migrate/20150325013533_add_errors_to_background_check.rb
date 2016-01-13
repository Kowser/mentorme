class AddErrorsToBackgroundCheck < ActiveRecord::Migration
  def change
  	add_column :background_checks, :error_msg, :string
  end
end

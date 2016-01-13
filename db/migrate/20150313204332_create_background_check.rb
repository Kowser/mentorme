class CreateBackgroundCheck < ActiveRecord::Migration
  def change
    create_table :background_checks do |t|
    	t.string 		:signature
    	t.string 		:status
    	t.string 		:checkr
    	t.integer		:user_id
    	t.timestamps
    end
  end
end

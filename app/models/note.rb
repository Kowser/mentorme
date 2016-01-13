class Note < ActiveRecord::Base
	default_scope { order(:created_at) }

  belongs_to :notable, polymorphic: true
  belongs_to :staff, class_name: User
  belongs_to :organization

  validates_presence_of :content, :staff, :notable, :organization
end

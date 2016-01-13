class Status < ActiveRecord::Base
	attr_accessor :skip_notification
	after_save :step_notification, unless: :skip_notification
	belongs_to :step
	belongs_to :user
	has_one :enrollment, through: :step

	validates :user, :step, presence: true
	validates_uniqueness_of :step_id, :scope => :user_id, message: "error: Please notify development team of duplicate 'status'."

private
	def step_notification
		step.email_notifications(user) if step.email_id && completed
	end
end




class CustomEmail < ActiveRecord::Base
	default_scope { order(:id) }
	belongs_to :organization
	has_many :steps, foreign_key: :email_id

	validates :subject, presence: true
	validates :body, presence: true
	validates	:text_message, presence: true
	validate :recipients_present
	
	def recipients(*user)
		emails = recipient_staff.try(:delete_if, &:blank?)
		emails += recipient_misc.gsub('; ', ';').split(';') if recipient_misc
		emails
	end

	def recipient_count
		count = recipients.try(:count)
		count += 1 if recipient_user
		count
	end

private
	def recipients_present
		if !recipient_user && recipient_staff.join.blank? && recipient_misc.blank?
			errors.add :recipient_staff, "At least one recipient is required"
		end
	end
end
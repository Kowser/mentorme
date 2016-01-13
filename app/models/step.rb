class Step < ActiveRecord::Base
	default_scope { order(:sequence, :id) }
	before_update :empty_fields,																									if: -> { step_type_changed? || template_changed? }

	belongs_to :email, class_name: CustomEmail
	belongs_to :form, class_name: CustomForm
	belongs_to :enrollment
	belongs_to :prerequisite_step, class_name: Step
	has_many :statuses, dependent: :destroy
	has_one :organization, through: :enrollment

	validates :enrollment, presence: true
	validates :title, presence: true
	validates :step_type, presence: true
	validates :template_fields,
						length: { minimum: 2, message: 'Select at least one option.' }, 		unless: -> { [nil, 'references', 'background'].include?(template)}
	validates :quantity, presence: true,																					if: -> { template == 'references' }
	validates :template, presence: true, 																					if: -> { step_type == 'template' }
	validates :form, presence: true, 																							if: -> { step_type == 'custom' }
	validates :sequence, presence: true, numericality: { only_integer: true }
	# , uniqueness: { scope: :enrollment_id, message: "already assigned." }

	def email_notifications(user)
		UserMailer.step_completed_email(user, email, self.enrollment.organization).deliver if email.recipient_user
		email.recipient_staff.concat([email.recipient_misc]).delete_if(&:blank?).each do |addressee|
		  OrganizationMailer.step_completed_email(addressee, email, self.enrollment.organization).deliver
		end
	end

private
	def empty_fields
		self.form = nil 							if self.step_type != 'custom'
		self.template = nil 					if self.step_type != 'template'
		self.template_fields = nil 		if self.step_type != 'template'
		self.quantity = nil 					if self.template != 'references'
	end
end

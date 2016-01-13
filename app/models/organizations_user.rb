class OrganizationsUser < ActiveRecord::Base
  attr_accessor :skip_notification, :joined_date
  before_save :set_joined_date,               if: -> { new_record? || organization_id_changed? }
  after_create :new_registration_email,       if: -> { skip_notification.blank? }
  after_create :update_progress,              if: -> { user.organizations_users.count > 1 }
  after_update :new_organization_email,       if: -> { organization_id_changed? && skip_notification.blank? }
  after_update :update_progress,              if: -> { organization_id_changed? }

	belongs_to :organization
	belongs_to :user
  has_many :notes, as: :notable, dependent: :destroy
  has_many :attachments, as: :attachable, dependent: :destroy
  accepts_nested_attributes_for :attachments, allow_destroy: true, reject_if: lambda { |attachment| attachment[:document].blank? }

	validates :user, presence: true
	validates :organization, presence: true
	validates_uniqueness_of :organization_id, :scope => :user_id, message: "already assigned."

  def name
    user.name
  end

  def enrolled
    (organization.try(:is_partner?) ? partner_joined : umbrella_joined).try(:strftime, "%m/%d/%Y")
  end

private
  def set_joined_date
    date = joined_date.blank? ? Date.today : joined_date
    organization.is_partner? ? self.partner_joined = date : self.umbrella_joined = date
  end

  def update_progress
    if enrollment = user.enrollments.find_by(organization_id: organization.id)
      enrollment.steps.where.not(template: ['references', nil]).each do |step|
        user.template = step.template
        user.validations = step.template_fields
        user.update_status(step, true) if user.valid?
      end
      enrollment.steps.where(template: 'references').each do |step|
        user.update_status(step, true) if user.references_submitted? || user.references.count > 0
      end
      user.update_progress(organization)
    end
  end

  def new_registration_email
    # notify reps when mentor/mentee signs up
    OrganizationMailer.new_user_registered_email(user, organization).deliver
  end

  def new_organization_email
    # notify staff/user when mentor/mentee reassigned to organization
    OrganizationMailer.new_user_assigned_email(user, organization).deliver
    UserMailer.new_partner_organization_email(user, organization).deliver
  end
end

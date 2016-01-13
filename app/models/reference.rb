class Reference < ActiveRecord::Base
  default_scope { order(:id) }
  attr_accessor :endorsement, :validations

  before_create :create_token
  after_save :notify_reference,                     if: ->(ref) { ref.new_record? || ref.email_changed? }
  belongs_to :user
  has_many :notes, as: :notable, dependent: :destroy

  validates :user, presence: true
  validates :name, presence: true,                  if: -> { validations.try(:include?, 'name') }
  validates :email, presence: true,                 if: -> { validations.try(:include?, 'email') }
  validates :phone, presence: true,                 if: -> { validations.try(:include?, 'phone') }
  validates :relation, presence: true,              if: -> { validations.try(:include?, 'relation') }

  before_update :mark_completed,                    if: :endorsement
  after_update :notify_user,                        if: :endorsement
  validates_presence_of :acquainted,            
                        :reliable,              
                        :follow_through,        
                        :strengths,             
                        :improvement_areas,         if: :endorsement

  def notify_reference
    UserMailer.reference_email(self).deliver
  end

private

  def mark_completed
    self.completed = true
  end

  def notify_user
    UserMailer.completed_reference_email(self).deliver
    if user.references.count == user.references.where(completed: true).count
      user.update(references_submitted: true) # update universal references submitted
      user.organizations_users.each do |ou|
        ou.update(references_submitted: true) # update individual org references submitted
      end
      user.steps.where(template: 'references').each do |step|
        user.update_progress(step.organization)
        OrganizationMailer.references_submitted_email(user, step.organization).deliver
      end
      UserMailer.references_submitted_email(user).deliver
    end
  end

  def create_token
    self.url_token = SecureRandom.urlsafe_base64
  end

end

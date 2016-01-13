class CheckIn < ActiveRecord::Base
  before_validation(on: :create) { set_attachment_organization }
  belongs_to :match
  has_and_belongs_to_many :users,   -> { where(role: ['Mentor', 'Mentee']) }, class_name: User
  has_and_belongs_to_many :mentors, -> { where(role: 'Mentor') }, class_name: User
  has_and_belongs_to_many :mentees, -> { where(role: 'Mentee') }, class_name: User
  has_many :ratings, inverse_of: :check_in, dependent: :destroy
  has_many :attachments, as: :attachable, dependent: :destroy
  has_one :organization, through: :match

  validates :length, presence: true
  validates :meeting_type, presence: true
  validates :location, presence: true,          if: -> { meeting_type == 'In Person' }
  validates :date, presence: true
  validates :next_date, presence: true
  validates :mentors, presence: true
  validates :mentees, presence: true
  validates_associated :ratings
  accepts_nested_attributes_for :ratings
  accepts_nested_attributes_for :attachments, allow_destroy: true, reject_if: lambda { |attachment| attachment[:document].blank? }

  def set_attachment_organization
    attachments.each { |attach| attach.organization = organization } if attachments.any?
  end
end
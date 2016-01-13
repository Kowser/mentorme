class Match < ActiveRecord::Base
  default_scope { order(:id) }
  after_create :notify_match

  belongs_to :organization
  belongs_to :staff, class_name: User
  has_many :check_ins, dependent: :destroy
  has_many :goals, dependent: :destroy
  has_many :ratings, through: :check_ins
  has_many :notes, as: :notable, dependent: :destroy

  has_and_belongs_to_many :users,   -> { where(role: ['Mentor', 'Mentee']) }, class_name: User
  has_and_belongs_to_many :mentors, -> { where(role: 'Mentor') }, class_name: User
  has_and_belongs_to_many :mentees, -> { where(role: 'Mentee') }, class_name: User

  validates :organization, presence: true
  validates :mentors, presence: true
  validates :mentees, presence: true
  validates :staff, presence: true

  def average_rating
    ratings.empty? ? "N/R" : (ratings.pluck(:rating).inject{ |sum, x| sum + x } / ratings.count.to_f).round(1)
  end

  def name
    users.map(&:name).sort.join(', ')
    # (mentors.map(&:name) + mentees.map(&:name)).sort.join(', ')
  end

private

  def notify_match
    users.each do |user|
      UserMailer.new_match_email(user, organization).deliver
    end
  end

end

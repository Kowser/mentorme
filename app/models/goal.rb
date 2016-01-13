class Goal < ActiveRecord::Base
  default_scope { order(deadline: :asc, created_at: :desc)}

  after_update :notifications
  after_create :notify_match_new_goal
  belongs_to :match
  belongs_to :completed_by, class_name: User
  belongs_to :verified_by, class_name: User

  validates :title, presence: true
  validates :match, presence: true
  
private
  def notifications
    if completed_changed? && completed
      OrganizationMailer.goal_completed_email(self).deliver
    elsif verified_changed? && verified
      UserMailer.goal_verified_email(self).deliver
    end
  end

  def notify_match_new_goal
    match.users.each do |user|
      UserMailer.new_goal_email(user, match.organization).deliver
    end
  end
end

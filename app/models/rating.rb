class Rating < ActiveRecord::Base
  after_save :notify_low_rating
  belongs_to :user
  belongs_to :check_in

  validates :check_in, presence: true
  validates :user, presence: true
  validates :rating, presence: { message: 'How do you feel about this meeting?' }
  validates :notes, presence: { message: 'Tell us what you did is required' }

private
  def notify_low_rating
    if rating_changed? && rating < 3
      OrganizationMailer.low_rating_email(self).deliver
    end
  end
end

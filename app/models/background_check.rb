class BackgroundCheck < ActiveRecord::Base
  attr_accessor :first_name, :middle_name, :last_name, :email, :phone, :zipcode, :dob, :ssn, :driver_license_number,
    :driver_license_state, :copy_requested, :validations
  belongs_to :user

  validates :user_id, presence: true
  validates :signature, length: { minimum: 5, message: '-- Please sign full name' },          if: -> { validations == 'true' }
  validates_presence_of :first_name,
                        :last_name,
                        :email,
                        :phone,
                        :zipcode,
                        :dob,                                                                 if: -> { validations == 'true' }
  validates :ssn, format: { with: /\A^\d{3}-\d{2}-\d{4}/ },                                   if: -> { validations == 'true' }

  def notify_dev(msg)
    OrganizationMailer.dev_team_email(msg).deliver
  end
end


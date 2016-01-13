class Enrollment < ActiveRecord::Base
	default_scope { order(:id).includes(:steps) }
	belongs_to :organization
	has_many :steps, inverse_of: :enrollment, dependent: :destroy
	accepts_nested_attributes_for :steps, allow_destroy: true

	validates :user_type, presence: { message: 'please select one' }
	validates :organization, presence: true
	validates :steps, presence: true
end
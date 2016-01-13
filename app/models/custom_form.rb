class CustomForm < ActiveRecord::Base
	default_scope { order(:id) }
	has_many :questions, class_name: CustomFormQuestion, foreign_key: :form_id, inverse_of: :form, dependent: :destroy
	has_many :responses, class_name: CustomFormResponse, foreign_key: :form_id, dependent: :destroy
	has_many :steps, foreign_key: :form_id
	belongs_to :organization
	accepts_nested_attributes_for :questions, allow_destroy: true

	validates :title, presence: { message: 'is needed '}
	validates :questions, presence: true
	validates :organization, presence: true
	validates_associated :questions
end

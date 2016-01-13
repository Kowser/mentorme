class CustomFormResponse < ActiveRecord::Base
	belongs_to :form, class_name: CustomForm
  belongs_to :user

	validates_presence_of :form, :user_id, :response
	validate :response_values
  validates_uniqueness_of :form_id, :scope => :user_id, message: "error: Please notify development team of duplication."

private
	def response_values
    form.questions.where(required: true).each do |field|
      if (response[field.id.to_s].is_a?(Array) ? (response[field.id.to_s] - ['']) : response[field.id.to_s]).blank?
        errors.add field.question, ""
      end
    end
  end
  
end
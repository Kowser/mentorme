class CustomFormQuestion < ActiveRecord::Base
	default_scope { order(:sequence, :id) }
	before_save :strip_answer_set, unless: -> { question_type == "text" }

	belongs_to :form, class_name: CustomForm
	validates :form, presence: true
	validates :question, presence: true
	validates :question_type, presence: { message: 'is needed'}
	validates_presence_of :collection, presence: { message: 'is needed'}, unless: ->(question) { question.question_type == "text" }
	validates :sequence, presence: true, numericality: { only_integer: true }
	# , uniqueness: { scope: :custom_form_id, message: "already assigned." }

	def answer_set
		self.collection.try(:gsub, ";", ";\r")
	end

private
	def strip_answer_set
		options = []
		self.collection.split(";").each { |option| options << option.strip }
		self.collection = options.join(';')
	end
end
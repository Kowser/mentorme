class Attachment < ActiveRecord::Base
  before_validation(on: :create) { set_organization }
  belongs_to :attachable, polymorphic: true
  belongs_to :user
  belongs_to :organization
  has_attached_file :document

  validates :document, presence: true
  validates :organization, presence: true
  validates :user, presence: true
  do_not_validate_attachment_file_type :document

  def name
    self.document_file_name
  end

private
	def set_organization
    if attachable && !organization
  		self.organization = case attachable_type
  			when 'OrganizationsUser' then attachable.organization
  			when 'CheckIn' then attachable.organization
  			when 'Organization' then attachable
  		end
    end
	end
end

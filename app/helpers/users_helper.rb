module UsersHelper
  def role_name
    params[:search].try(:[], :role).try(:pluralize)
  end
end

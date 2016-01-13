class Search < ActiveRecord::Base
	attr_accessor :keyword, :tags, :created_at, :rating, :id, :signed_in, :matched, :active, :sort, :completed,
		:contacted, :match_id, :length, :meeting_type, :assignees, :role, :staff_id, :status

	def self.goals(profile, params)
		params = compact(params) || {}
		search_params = params.dup
			search_params.delete(:keyword)
			search_params.delete(:created_at)
		keyword_params = "title ILIKE ?", "%#{params[:keyword]}%"
		created_params = "goals.created_at between ? AND ?", date = Date.strptime(params[:created_at], "%m/%d/%Y"),
			date + 1.day if params[:created]

		profile.goals
			.where(keyword_params)
			.where(created_params)
			.where(search_params)
	end

	def self.check_ins(profile, params)
		params = compact(params) || {}
		rating_params = "ratings.rating = ?", params[:rating].to_i if params[:rating]
		search_params = params.dup
			search_params.delete(:rating)

		profile.check_ins
			.includes(:ratings).where(rating_params)
			.where(search_params)
			.reorder(date: :desc)			
	end

	def self.matches(profile, params)
		params = compact(params) || {}
		keyword_params = "users.first_name || users.last_name ILIKE ?", "%#{params[:keyword]}%" if params[:keyword]
		params.delete(:keyword)
		params[:active] = params[:active] || true
		profile.matches
			.joins(:users).where(keyword_params)
			.where(params)
			.uniq
	end

	def self.users(profile, params)
		params = compact(params) || {}
	  keyword_params = "first_name || last_name || login ILIKE ?", "%#{params[:keyword]}%" if params[:keyword]
	  tag_params = "organizations_users.tags ILIKE ?", "%#{params[:tags]}%" if params[:tags]

		users = profile.users
			.where("organizations_users.active = ?", params[:active] || true)
			.where(role: params[:role] || ['Mentor', 'Mentee'])
			.where(keyword_params)
			.where(tag_params)

		users = users.where.not(sign_in_count: 0) if params[:signed_in] == 'true'
		users = users.where(sign_in_count: 0) if params[:signed_in] == 'false'

		if params[:matched] == 'true'
			users = users.joins("LEFT OUTER JOIN matches_users ON users.id = matches_users.user_id").where("matches_users.id IS NOT NULL")
		elsif params[:matched] == 'false'
			users = users.joins("LEFT OUTER JOIN matches_users ON users.id = matches_users.user_id").where("matches_users.id IS NULL")
		end

		users = case params[:sort]
		when 'sign_up'
			profile.is_partner? ? users.order("organizations_users.partner_joined DESC") : users.order("organizations_users.umbrella_joined DESC")
		when 'progress'
			users.order("organizations_users.progress DESC")
		else
			users.order("users.last_name ASC, users.first_name ASC")
		end
		users
	end

	def self.references(profile, params)
		params = compact(params) || {}
		keyword_params = "users.first_name || users.last_name || name ILIKE ?", "%#{params[:keyword]}%" if params[:keyword]
		params.delete(:keyword)
		references = profile.references.where(params).joins(:user).where(keyword_params)
		references.order('users.first_name')
	end

	def self.background_checks(profile, params)
		params = compact(params) || {}
		keyword_params = "users.first_name || users.last_name ILIKE ?", "%#{params[:keyword]}%" if params[:keyword]
		params.delete(:keyword)
		background_checks = profile.background_checks.where(params).joins(:user).where(keyword_params)
		background_checks.order('users.first_name')
	end

private
	def self.compact(params)
		params.try(:delete_if) do |k,v|
			v.blank?
		end
	end

end

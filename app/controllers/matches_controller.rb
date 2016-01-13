class MatchesController < ApplicationController
  before_action :authenticate_partner!, except: [:index]
  before_action :show_selector, only: [:index, :find]
  before_action :crumbs

  def index
    @search = params[:search] ? Search.new(search_params) : Search.new
    @matches = Search.matches(@current_profile, params[:search]).paginate(page: params[:page], per_page: 10)
  end

  def new
    @match = Match.new
    add_breadcrumb "New Match"
    render 'form'
  end

  def create
    @match = @current_profile.matches.new(match_params)
    if @match.save
      track_match_event("new match")
      flash[:success] = 'Match created.'
      redirect_to action: 'index'
    else
      flash.now[:alert] = fix_errors_message(@match)
      add_breadcrumb "New Match"
      render 'form'
    end
  end

  def edit
    @match = @current_profile.matches.find(params[:id])
    add_breadcrumb "Edit Match"
    render 'form'
  end

  def update
    @match = @current_profile.matches.find(params[:id])
    if @match.update(match_params)
      track_match_event("update match")
      flash[:success] = 'Match updated successfully!'
      redirect_to action: 'index'
    else
      flash.now[:alert] = fix_errors_message(@match)
      add_breadcrumb "Edit Match"
      render 'form'
    end
  end

protected
  def crumbs
    add_breadcrumb "MATCHES", current_user.is_partner? ? organization_matches_path : user_matches_path
  end

private
  def match_params
    params.require(:match).permit(Parameters::MATCH_PARAMS)
  end

  def track_match_event(label)
    track_event(
      label,
      id: @match.id,
      org_id: @current_profile.id,
      staff_id: @match.staff_id,
      mentor_ids: @match.mentor_ids,
      mentee_ids: @match.mentee_ids
    )
  end

end

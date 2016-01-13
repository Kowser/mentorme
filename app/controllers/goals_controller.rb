class GoalsController < ApplicationController
  before_action :authenticate_partner!, only: [:create, :destroy]

  def index
    @search = params[:search] ? Search.new(search_params) : Search.new
    @goals = Search.goals(@current_profile, params[:search]).paginate(page: params[:page], per_page: 25)
    @match_names = @current_profile.matches.where(id: @current_profile.check_ins.pluck(:match_id).uniq).map(&:name).sort
    add_breadcrumb "GOALS"
  end

  def create
    respond_to do |format|
      format.html {
        ids = params[:match_ids] == ['all'] ? :all : params[:match_ids]

        if ids.blank? || goal_params[:title].blank?
          flash[:alert] = 'Error: No matches selected or title blank'
        else
          @current_profile.matches.find(ids).each do |match|
            match.goals.create(goal_params)
          end
        end

        redirect_to action: 'index'
      }

      format.js {
        @match = Match.find_by(id: params[:selected][:match_id])
        render "#{params[:selected][:match_type]}.js"
      }
    end
  end

  def update
    @goal = Goal.find(params[:id])
    merged_params = goal_params
    merged_params = goal_params.merge(completed_by: current_user) if goal_params[:completed]
    merged_params = goal_params.merge(verified_by: current_user) if goal_params[:verified]
    @goal.update(merged_params)

    respond_to do |format|
      format.html { redirect_to :back }
      format.js   { render nothing: true }
    end
  end

  def destroy
    Goal.find(params[:id]).destroy
    respond_to do |format|
      format.html { redirect_to :back }
      format.js   { render nothing: true }
    end
  end

private
  def goal_params
    params.require(:goal).permit(Parameters::GOAL_PARAMS)
  end
end

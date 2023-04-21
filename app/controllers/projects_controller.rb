class ProjectsController < ApplicationController
  before_action :get_project, except: [:index]

  def show
    @due_date = @project.due_date
    @project_supports = @project.project_supports
    @percentage = (@project.percentage_of_reaching_goal * 100).round(2)
  end

  private

  def get_project
    @project = Project.is_now_on_sale.find_by_id(params[:id])

    unless @project
      flash[:alert] = "沒有這個募資專案"
      redirect_to root_path
      return
    end
  end
end

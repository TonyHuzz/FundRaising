class ProjectsController < ApplicationController
  before_action :is_login?, except: [:show, :search]
  before_action :get_project, only: [:show]
  before_action :get_project_for_update, only: [:edit, :update, :destroy]

  def show
    @due_date = @project.due_date
    @project_supports = @project.project_supports.is_published
    @percentage = (@project.percentage_of_reaching_goal * 100).round(2)
  end

  def new
    @project = Project.new
    @categories = Category.is_published
  end

  def create
    @project = Project.create(project_permit.merge(project_owner: current_user.project_owner))

    if @project.valid?
      redirect_to edit_project_path(@project)
    else
      flash[:alert] = @project.errors.messages.map{ |key, value| "#{t(key)}: #{value[0]}" }
      redirect_to new_project_path
    end
  end

  def edit
    @project_supports = @project.project_supports
    @new_project_support = ProjectSupport.new
    @first_project_support = @project_supports.first
  end

  def update
    if @project.update(project_permit)
      flash[:notice] = "更新成功"
    else
      flash[:alert] = @project.errors.messages.map{ |key, value| "#{t(key)}: #{value[0]}" }
    end

    redirect_to edit_project_path(@project)
  end

  def destroy
    if @project.pledges.count > 0
      flash[:alert] = "募資專案: #{@project.name} 已經有人贊助，無法刪除"
    else
      @project.cancel!
      flash[:notice] = "募資專案: #{@project.name} 已經被刪除"
    end

    redirect_to owner_projects_path
  end


  def owner
    @project_owner = current_user.project_owner

    @projects = @project_owner.projects.where.not(status: [:cancel])
  end

  def owner_update
    @project_owner = current_user.project_owner
    @project_owner.update(project_owner_permit)

    redirect_to action: :owner
  end

  def search
    @key_words = params[:keyWord]
    if @key_words
      word = "%#{@key_words}%"      #前後加上%%是代表模糊搜尋
      @projects = Project.eager_load(:user).is_now_on_sale.where("projects.name LIKE ? or brief LIKE ? or users.name LIKE ?", word, word, word)   #eager_load指的是做一次left outer_join;eager_load(:user)裡面的 :user 必須是 project model 裡面的 has_one :user
    else
      @projects = []
    end
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

  def get_project_for_update
    @project = Project.find_by(id: params[:id], project_owner: current_user.project_owner)

    unless @project
      flash[:alert] = "沒有這個募資專案"
      redirect_to root_path
      return
    end
  end

  def is_login?
    unless current_user
      flash[:error] = "您尚未登入"
      redirect_to user_session_path
      return
    end
  end

  def project_owner_permit
    params.require(:project_owner).permit([:description, :cover_image])
  end


  def project_permit
    params.require(:project).permit([:category_id, :name, :brief, :description, :cover_image, :ad_url, :goal, :due_date, :status])
  end

end

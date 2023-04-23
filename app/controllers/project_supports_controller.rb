class ProjectSupportsController < ApplicationController
  before_action :get_project_for_update
  before_action :get_project_support, except: [:create]

  def create
    @project_support = ProjectSupport.create(
      project: @project,
      name: "未命名",
      description: "未填寫",
      price: 0
    )

    if !@project_support.valid?
      flash[:alert] = @project_support.errors.messages.map{ |key, value| "#{t(key)}: #{value[0]}" }
    else
      flash[:notice] = "贊助方案新增成功"
    end

    redirect_to edit_project_path(@project)
  end

  def update
    if @project_support.update(project_support_permit)
      flash[:notice] = "更新成功"
    else
      flash[:alert] = @project_support.errors.messages.map{ |key, value| "#{t(key)}: #{value[0]}" }
    end

    redirect_to edit_project_path(@project)
  end

  def destroy
    if @project_support.pledges.count > 0
      flash[:alert] = "贊助方案: #{@project_support.name} 已經有人贊助，無法刪除"
    else
      @project_support.destroy!
      flash[:notice] = "贊助方案: #{@project_support.name} 已經被刪除"
    end

    redirect_to edit_project_path(@project)
  end

  private

  def get_project_for_update
    @project = Project.find_by(id: params[:id], project_owner: current_user.project_owner)

    unless @project
      flash[:alert] = "沒有這個募資專案"
      redirect_to root_path
      return
    end
  end

  def get_project_support
    @project_support = @project.project_supports.find_by(id: params[:project_support_id])

    unless @project_support
      flash[:alert] = "沒有這個贊助方案"
      redirect_to edit_project_path(@project)
      return
    end
  end


  def project_support_permit
    params.require(:project_support).permit([:name, :description, :price, :status])
  end
end

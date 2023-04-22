class PledgesController < ApplicationController
  before_action :is_login?
  before_action :get_project_support, only: [:create]
  before_action :get_pledge, except: [:create, :index]


  def index
    @pledges = current_user.validated_pledges
  end

  def show
    case @pledge.status_before_type_cast
    when Pledge.statuses[:paid]
      render "paid"
    when Pledge.statuses[:not_paid]
      render "not_paid"
    else
      flash[:alert] = "沒有此贊助"
      redirect_to root_path
      return
    end
  end

  def create
    @pledge = Pledge.create({
                              user: current_user,
                              project_support: @project_support,
                              project_name: @project_support.project.name,
                              support_name: @project_support.name,
                              support_price: @project_support.price,
                              quantity: params[:quantity]
                            })

    redirect_to mpg_payments_path(pledge_id: @pledge.id)
  end

  private

  def is_login?
    unless current_user
      flash[:error] = "您尚未登入"
      redirect_to user_session_path
      return
    end
  end

  def get_project_support
    @project_support = ProjectSupport.is_published.find_by_id(params[:id])

    unless @project_support
      flash[:alert] = "沒有這個贊助方案"
      redirect_to root_path
      return
    end
  end

  def get_pledge
    @pledge = Pledge.find_by(id: params[:id], user: current_user)

    unless @pledge
      flash[:alert] = "沒有此贊助"
      redirect_to root_path
      return
    end
  end

end

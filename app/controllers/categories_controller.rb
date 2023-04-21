class CategoriesController < ApplicationController
  before_action :get_category, only: [:show]

  def show
    @projects = @category.projects.is_now_on_sale
  end


  private

  def get_category
    @category = Category.is_published.find_by(id: params[:id])

    unless @category
      flash[:alert] = "沒有此類別"
      redirect_to root_path
      return
    end
  end
end

class HomeController < ApplicationController
  def index
    @projects = Project.is_now_on_sale
    @successful_projects = Project.succeeded_and_done
    @past_projects = Project.past_projects
    @slider_items = SliderItem.is_published.order(:order_index)
  end
end

class Pledge < ApplicationRecord
  belongs_to :user
  belongs_to :project_support

  has_one :payment
  has_one :project, through: :project_support

  enum status: [:not_selected_yet, :not_paid, :paid, :canceled]

  validates :project_name, :support_name, presence: true
  validates_numericality_of :support_price, greater_than_or_equal_to: 0
  validates_numericality_of :quantity, greater_than_or_equal_to: 1
  validate :is_user_project_owner?

  def end_price
    support_price * quantity
  end

  def paid!
    self.issue_date = Time.now
    super           #super是指原本的動作

    project.update_status_if_reaching_goal!
  end

  def status_to_string
    case status_before_type_cast
    when Pledge.statuses[:not_selected_yet]
      return "未選擇"
    when Pledge.statuses[:not_paid]
      return "未付款"
    when Pledge.statuses[:paid]
      return "已付款"
    when Pledge.statuses[:canceled]
      return "已取消"
    else
      return "狀態未明"
    end
  end

  private

  def is_user_project_owner?
    if project_support.project.project_owner.user == user
      errors.add(:user, "不可以投資自己的專案")
    end
  end
end

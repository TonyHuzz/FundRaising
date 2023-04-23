class ProjectSupport < ApplicationRecord
  belongs_to :project
  has_many :pledges
  has_many :paid_pledges, -> { where(status: [:paid]) }, class_name: 'Pledge'     #可以抓到pledge status是 :paid的

  enum status: [:is_hidden, :is_published]

  validates :name, :description, presence: true
  validates_numericality_of :price, greater_than_or_equal_to: 0


  def status_to_string
    case status_before_type_cast
    when ProjectSupport.statuses[:is_hidden]
      return "隱藏"
    when ProjectSupport.statuses[:is_published]
      return "顯示中"
    else
      return "狀態未明"
    end
  end
end

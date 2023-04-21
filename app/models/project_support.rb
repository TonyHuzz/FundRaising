class ProjectSupport < ApplicationRecord
  belongs_to :project
  has_many :pledges
  has_many :paid_pledges, -> { where(status: [:paid]) }, class_name: 'Pledge'     #可以抓到pledge status是 :paid的

  enum status: [:is_hidden, :is_published]

  validates :name, :description, presence: true
  validates_numericality_of :price, greater_than_or_equal_to: 0

end

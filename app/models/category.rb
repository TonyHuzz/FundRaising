class Category < ApplicationRecord
  has_many :projects

  enum status: [:is_hidden, :is_published]

  validates :name, presence: true
end

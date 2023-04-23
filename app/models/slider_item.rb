class SliderItem < ApplicationRecord

  enum status: [:is_hidden, :is_published]

  mount_uploader :cover_image, CoverImageUploader

  validates :cover_image, presence: true
end

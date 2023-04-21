class ProjectOwner < ApplicationRecord
  belongs_to :user
  has_many :projects

  mount_uploader :cover_image, CoverImageUploader


end

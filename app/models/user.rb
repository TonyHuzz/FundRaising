class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable#, :omniauthable

  has_many :pledges
  has_many :validated_pledges, -> { where(status: [:not_paid, :paid]) }, class_name: "Pledge"
  has_one :project_owner

  validates :name, presence: true

  mount_uploader :avatar, CoverImageUploader


  def project_owner
    @project_owner = super

    if @project_owner.blank?
      @project_owner = ProjectOwner.create(user: self)
    end

    return @project_owner
  end

end

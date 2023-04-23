class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :omniauthable, omniauth_providers: [:google_oauth2]

  has_many :pledges
  has_many :validated_pledges, -> { where(status: [:not_paid, :paid]) }, class_name: "Pledge"
  has_one :project_owner

  validates :name, presence: true

  mount_uploader :avatar, CoverImageUploader


  def self.from_omniauth(access_token)
    data = access_token.info
    user = User.where(email: data['email']).first


    # Uncomment the section below if you want users to be created if they don't exist
    unless user
      user = User.create(
        name: data['name'],
        email: data['email'],
        password: Devise.friendly_token[0,20],
        )
      user.skip_confirmation!
      user.save
    end
    user
  end

  def project_owner
    @project_owner = super

    if @project_owner.blank?
      @project_owner = ProjectOwner.create(user: self)
    end

    return @project_owner
  end
end

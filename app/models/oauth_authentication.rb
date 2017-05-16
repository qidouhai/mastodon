class OauthAuthentication < ApplicationRecord
  belongs_to :user, required: true
  has_many :pixiv_follows, dependent: :delete_all

  validates :provider, :uid, presence: true
  validates :user_id, uniqueness: { scope: :provider }
  validates :provider, inclusion: Devise.omniauth_configs.keys.map(&:to_s)
  validates :uid, uniqueness: { scope: :provider }

  before_destroy :prevent_destory_if_initial_password_usage_is_exists

  private

  def prevent_destory_if_initial_password_usage_is_exists
    throw(:abort) if user.initial_password_usage
  end
end

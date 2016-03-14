# == Schema Information
#
# Table name: tours
#
#  id                :integer          not null, primary key
#  name              :string(255)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  custom_domain     :string(255)
#  creator_id        :integer
#  use_custom_domain :boolean          default(FALSE)
#  custom_logo_url   :string(255)
#  info_text         :text
#
class Tour < ActiveRecord::Base
  before_save :downcase_custom_domain

  has_many :seasons, dependent: :destroy
  has_many :events, through: :seasons
  has_many :scores, through: :events

  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships

  has_many :admin_memberships, -> { where(role: "admin") },
           class_name: "Membership"
  has_many :admins, through: :admin_memberships, source: :user

  belongs_to :creator, class_name: "User", foreign_key: :creator_id

  validates :name, presence: true, uniqueness: true
  validates :custom_domain, presence: true, uniqueness: true


  def current_season
    @current_season ||= begin
      seasons = self.seasons.not_closed
      seasons.last
    end
  end

  def role_for(user)
    memberships.find_by(user: user).try :role
  end

  def downcase_custom_domain
    self.custom_domain = custom_domain.downcase unless custom_domain.blank?
  end
end

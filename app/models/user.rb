# == Schema Information
#
# Table name: users
#
#  id                              :integer          not null, primary key
#  email                           :string(255)      default(""), not null
#  is_public                       :boolean          default(TRUE)
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  swedish                         :boolean          default(FALSE)
#  last_login_at                   :datetime
#  last_logout_at                  :datetime
#  last_activity_at                :datetime
#  last_login_from_ip_address      :string(255)
#  reset_password_token            :string(255)
#  reset_password_token_expires_at :datetime
#  reset_password_email_sent_at    :datetime
#  remember_me_token               :string(255)
#  remember_me_token_expires_at    :datetime
#  crypted_password                :string(255)
#  salt                            :string(255)
#  activation_state                :string(255)
#  activation_token                :string(255)
#  activation_token_expires_at     :datetime
#  first_name                      :string(255)
#  last_name                       :string(255)
#  invitor_id                      :integer
#  partially_registered            :boolean          default(FALSE)
#  name                            :string(255)
#
class User < ActiveRecord::Base
  has_secure_token :session_token

  attr_accessor :remember_me, :authentications_attributes

  # leaderboard attributes
  attr_accessor :num_events, :average, :points_array, :total_points, :old_average,
                :old_total_points, :position, :prev_position

  # membership attributes
  attr_accessor :nickname

  authenticates_with_sorcery! do |config|
    config.authentications_class = Authentication
  end

  before_save :downcase_email

  # validations
  validates :email, uniqueness: true, email: true, allow_blank: true
  validates :name,  presence: true

  validate do |record|
    # partially_registered users are created when inviting them to a tour
    # and don't initially have a password set
    unless record.salt.present? || record.partially_registered?
      record.errors.add(:password, "can't be blank") if record.password.nil?
    end
  end

  validates :password, length: { minimum: 3, allow_nil: true }

  # scopes
  default_scope -> { order(:name) }
  scope :is_public, -> { where is_public: true }

  # associations
  has_many :memberships, dependent: :destroy
  has_many :tours, through: :memberships

  has_many :scores, dependent: :destroy
  has_many :events, through: :scores

  has_many :authentications, dependent: :destroy
  accepts_nested_attributes_for :authentications

  has_many :inviteds, foreign_key: :invitor_id, class_name: "User"
  belongs_to :invitor, class_name: "User"

  def user_events
    UserEvent.where("data -> 'user_id' = '#{id}'")
  end

  def downcase_email
    self.email = email.downcase unless email.blank?
  end

  def friend_ids
    tours.map(&:user_ids).flatten - [id]
  end

  def active?
    activation_state == "active"
  end

  def needs_password?
    crypted_password.nil?
  end

  def setup_activation!
    send(:setup_activation)
  end

  def has_role?(role, tour)
    if role.to_s == "admin" && tour.creator == self
      return true
    end
    membership_for(tour).role.to_s == role.to_s
  end

  def membership_for(tour)
    self.memberships.where("tour_id = #{tour.id}").first
  end

  def short_name
    names = self.name.split(" ")
    if names.length > 1
      name = "#{names[0]} #{names[1][0]}"
    else
      name = "#{names[0]}"
    end
    name
  end

  def short_name_for(tour)
    nick = membership_for(tour).nickname
    if nick.blank?
      name = self.short_name
    else
      names = nick.split(" ")
      if names.length > 1
        name = "#{names[0]} #{names[1][0]}"
      else
        name = "#{names[0]}"
      end
    end
    name
  end

  def name_for(tour)
    membership = self.membership_for(tour)
    nick = membership.nil? ? self.name : membership.nickname
    name = nick.blank? ? self.name : nick
  end
end

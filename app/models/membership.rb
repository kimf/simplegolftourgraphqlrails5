# == Schema Information
#
# Table name: memberships
#
#  id       :integer          not null, primary key
#  tour_id  :integer
#  user_id  :integer
#  role     :integer          default(0)
#  nickname :string(255)
#

class Membership <  ActiveRecord::Base
  belongs_to :user
  belongs_to :tour

  validates :user, :tour, presence: true
  validates_uniqueness_of :user_id, scope: :tour_id

  enum role:   [ :player, :admin ]
end

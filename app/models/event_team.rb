# == Schema Information
#
# Table name: event_teams
#
#  id           :integer          not null, primary key
#  event_id     :integer
#  user_ids     :integer          is an Array
#  points       :decimal(, )
#  event_points :decimal(, )
#  created_at   :datetime
#  updated_at   :datetime
#

class EventTeam < ActiveRecord::Base

  belongs_to :event

  attr_accessor :position

  validates :points, :user_ids, :event_id, presence: true


  def users
    User.find(self.user_ids)
  end

  def user_names
    names = []
    tour = self.event.tour
    users.each do |u|
      names << u.short_name_for(tour)
    end
    names
  end
end

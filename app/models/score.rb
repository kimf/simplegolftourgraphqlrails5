# == Schema Information
#
# Table name: scores
#
#  id           :integer          not null, primary key
#  user_id      :integer
#  points       :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  event_id     :integer
#  event_points :decimal(, )
#  season_id    :integer
#

class Score < ActiveRecord::Base
  belongs_to :user
  belongs_to :season
  belongs_to :event

  delegate :tour, to: :season, allow_nil: false

  attr_accessor :position
end

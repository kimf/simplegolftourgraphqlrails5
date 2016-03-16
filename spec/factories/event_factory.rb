# == Schema Information
#
# Table name: events
#
#  id           :integer          not null, primary key
#  starts_at    :datetime
#  created_at   :datetime
#  updated_at   :datetime
#  status       :integer          default(0)
#  scoring_type :integer          default(0)
#  team_event   :boolean          default(FALSE)
#  course       :string(255)
#  gametype     :string(255)
#  season_id    :integer
#

FactoryGirl.define do
  factory :event do

    starts_at    Time.now.in_time_zone
    course       'Nynäshamns GK'
    gametype     :stableford
    scoring_type :points
    team_event   false

    association :season
  end
end


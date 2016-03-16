# == Schema Information
#
# Table name: seasons
#
#  id                  :integer          not null, primary key
#  tour_id             :integer
#  aggregate_count     :integer
#  points              :string(255)      default([]), is an Array
#  closed_at           :datetime
#  created_at          :datetime
#  updated_at          :datetime
#  use_reversed_points :boolean          default(FALSE)
#

FactoryGirl.define do
  factory :season do
    aggregate_count Season::DEFAULT_AGGREGATE_COUNT
    points Season::DEFAULT_POINTS_ARRAY

    association :tour
  end
end

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

require 'active_record'
require File.expand_path('../../../app/models/score', __FILE__)

describe Score do

end

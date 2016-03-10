# == Schema Information
#
# Table name: user_events
#
#  id         :integer          not null, primary key
#  event_name :string(255)
#  data       :hstore
#  created_at :datetime
#

class UserEvent < ActiveRecord::Base
  include BelongsToHstore::Association
  store_accessor :data

  belongs_to_hstore :data, :user

  #validates :data, inclusion: { in: %w{white, red, blue} }


  #to query: UserEvent.where("data -> 'user_id' = '1'")
end

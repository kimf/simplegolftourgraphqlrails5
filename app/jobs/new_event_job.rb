class NewEventJob
  include SuckerPunch::Job

  def perform(event_id, creator_id)
    ActiveRecord::Base.connection_pool.with_connection do
      event  = Event.find(event_id)
      tour   = event.tour
      sender = User.find(creator_id)

      # tour.users.select{|u| u.active? && !u.email.blank? }.each do |user|
      #   UserMailer.new_event(user, event, sender).deliver
      # end

      TrackUserEventJob.new.async.perform(:created_event,
        {user_id: creator_id, tour_id: tour.id, event_id: event.id, gametype: event.gametype, scoring_type: event.scoring_type})
    end
  end

end

class EventScoredJob
  include SuckerPunch::Job

  def perform(event_id, scorer_id)
    ActiveRecord::Base.connection_pool.with_connection do
      event  = Event.find(event_id)
      tour   = event.tour
      scorer = User.find(scorer_id)

      tour.users.select{|u| !u.email.blank? }.each do |user|
        UserMailer.scored_event(user, event, scorer).deliver
      end

      TrackUserEventJob.new.async.perform(:scored_event,
        {user_id: scorer_id, event_id: event_id, tour_id: tour.id, gametype: event.gametype, scoring_type: event.scoring_type})
    end
  end

end

class InviteToTourJob
  include SuckerPunch::Job

  def perform(user_id, tour_id, sender_id)
    ActiveRecord::Base.connection_pool.with_connection do
      user   = User.find(user_id)
      tour   = Tour.find(tour_id)
      sender = User.find(sender_id)

      UserMailer.added_to_tour(user, tour, sender).deliver
      TrackUserEventJob.new.async.perform(:invited_user,
        {user_id: sender_id, tour_id: tour_id, invited_user: user_id})
    end
  end

end

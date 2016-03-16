class NewSeasonJob
  include SuckerPunch::Job

  def perform(tour_id, changer_id)
    ActiveRecord::Base.connection_pool.with_connection do
      tour   = Tour.find(tour_id)
      sender = User.find(changer_id)

      tour.users.select{|u| u.active? && !u.email.blank? && u != sender }.each do |user|
        UserMailer.new_season(user, tour, sender).deliver
      end

      TrackUserEventJob.new.async.perform(:created_new_season, {user_id: changer_id, tour_id: tour.id})
    end
  end

end

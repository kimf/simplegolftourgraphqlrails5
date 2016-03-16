class RoleChangedJob
  include SuckerPunch::Job

  def perform(user_id, tour_id, new_role, changer_id)
    ActiveRecord::Base.connection_pool.with_connection do
      user    = User.find(user_id)
      tour    = Tour.find(tour_id)
      changer = User.find(changer_id)

      UserMailer.role_changed(user, new_role, tour, changer).deliver

      TrackUserEventJob.new.async.perform(:changed_user_role, {
        current_user_id: changer_id, user_id: user_id, tour_id: tour_id, new_role: new_role})
    end
  end

end

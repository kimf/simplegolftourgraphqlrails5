class TrackUserEventJob
  include SuckerPunch::Job

  def perform(event_name, data={})
    ActiveRecord::Base.connection_pool.with_connection do
      UserEvent.create(event_name: event_name.to_s, data: data)

      # logged_in, created_tour, signed_up, edited_profile, activated, canceled_event
      # removed_user, scored_event, invited_user, created_event, changed_user_role
      if ["scored_event", "invited_user", "created_tour", "signed_up"].include?(event_name.to_s)
        NotifyAdminJob.new.async.perform(event_name, data)
      end

    end
  end

end

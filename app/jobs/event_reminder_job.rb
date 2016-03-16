class EventReminderJob
  include SuckerPunch::Job

  def perform(event_id)
    ActiveRecord::Base.connection_pool.with_connection do
      event  = Event.find(event_id)
      tour   = event.tour

      tour.users.select{|u| u.active? && !u.email.blank? }.each do |user|
        UserMailer.event_reminder(user, event).deliver
      end
    end
  end

end

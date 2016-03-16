class ActivationReminderJob
  include SuckerPunch::Job

  def perform(tour_id)
    ActiveRecord::Base.connection_pool.with_connection do
      tour  = Tour.find(tour_id)

      tour.users.select{|u| !u.active? && !u.email.blank? }.each do |user|
        UserMailer.activation_needed_reminder_email(user, tour).deliver
      end
    end
  end

end

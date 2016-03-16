require 'prowler'

class NotifyAdminJob
  include SuckerPunch::Job

  def perform(event_name, data={})
    ActiveRecord::Base.connection_pool.with_connection do

      Prowler.configure do |config|
        #config.root_certificates  = "/usr/local/etc/openssl/cert.pem"
        #config.api_key    = 'bdeb5d944b74fd18440ca8a9aa96bc189299408f'
        config.application = 'Simple Golftour'
      end

      user  = User.find(data[:user_id])
      tour  = Tour.find(data[:tour_id]) if data[:tour_id].present?
      event = Event.find(data[:event_id]) if data[:event_id].present?

      case event_name
      when :scored_event
        gametype = data[:gametype]
        scoring_type = data[:scoring_type]

        subject = "An event was scored"
        message = "#{user.name} just scored an event in #{tour.name}. They played #{gametype} with #{scoring_type}"
      when :invited_user
        invited_user = User.find(data[:invited_user])

        subject = "A user was invited"
        message = "#{invited_user.name} just got invited to #{tour.name} by #{user.name}."
      when :created_tour
        subject = "New Tour, New Tour!"
        message = "#{tour.name} was created by #{user.name}."
      when :signed_up
        subject = "Weppa, A new signup."
        message = "The user #{user.name} just signed up."
      else
        return false
      end

      Prowler.send_notifications = Rails.env.production?

      ['bdeb5d944b74fd18440ca8a9aa96bc189299408f', '1055703aea5e6bb605cc7a039cd8914dffe1b761'].each do |key|
        prowler = Prowler.new(api_key: key)
        prowler.notify subject, message + "\nhttp://admin.simplegolftour.com"
      end
    end

  end

end

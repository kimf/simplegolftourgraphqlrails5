class UserMailer < ActionMailer::Base
  default from: "Simple Golftour <contact@simplegolftour.com>"
  layout 'emails'

  def activation_needed_email(user)
    headers['X-Mailgun-Tag'] = "welcome_email"
    @user = user
    @url  = "#{host_url}users/activate/#{@user.activation_token}"
    mail(to: user.email, subject: "Thanks and welcome to Simple Golftour")
  end

  def activation_needed_reminder_email(user, tour)
    headers['X-Mailgun-Tag'] = "welcome_email_reminder"
    @user = user
    @tour = tour
    @invitor = @user.invitor

    @user.setup_activation! && @user.save if @user.activation_token.nil?

    @url  = "#{host_url}users/activate/#{@user.activation_token}"
    mail(to: user.email, subject: "#{@invitor.name} still wants you to join #{@tour.name}")
  end

  def activation_success_email(user)
    headers['X-Mailgun-Tag'] = "activated_email"
    @user = user

    if !user.memberships.select{|m| m.admin? }.empty?
      @url = "https://www.simplegolftour.com"
      mail(to: user.email, subject: "You're activated, what now?")
    end
  end

  def welcome_from_facebook_email(user)
    headers['X-Mailgun-Tag'] = "welcome_from_facebook"
    @user = user
    @url  = "#{host_url}login"
    mail(to: user.email, subject: "Thanks and welcome to Simple Golftour")
  end

  def reset_password_email(user)
    headers['X-Mailgun-Tag'] = "reset_password"
    @user = user
    @url  = "#{host_url}password_resets/#{@user.reset_password_token}/edit"
    mail(to: user.email, subject: "Here's how to reset your password")
  end

  def added_to_tour(user, tour, sender)
    headers['X-Mailgun-Tag'] = "added_to_tour"
    @user = user
    @tour   = tour
    @sender = sender

    if @user.active?
      @url  = "#{host_url}tours/#{@tour.id}"
    else
      @user.setup_activation! if @user.activation_token.nil?
      @url  = "#{host_url}users/activate/#{@user.activation_token}"
    end
    mail(to: user.email, subject: "#{@sender.name} added you to #{@tour.name}")
  end

  def new_event(user, event, sender)
    headers['X-Mailgun-Tag'] = "new_event"
    @event  = event
    @tour   = event.tour
    @sender = sender

    @url  = "#{host_url}tours/#{@tour.id}/events/#{@event.id}"
    mail(to: user.email, subject: "#{@sender.name} added an event in #{@tour.name}" )
  end

  def event_reminder(user, event)
    headers['X-Mailgun-Tag'] = "event_reminder"
    @event = event
    @tour  = event.tour
    @user  = user

    @url  = "#{host_url}tours/#{@tour.id}/events/#{@event.id}"
    mail(to: user.email, subject: "Next event in #{@tour.name}: #{@event.starts_at.to_s(:short)}" )
  end

  def scored_event(user, event, scorer)
    headers['X-Mailgun-Tag'] = "scored_event"
    @event  = event
    @tour   = event.tour
    season  = event.season
    @scorer = scorer

    @tour_leaderboard = season.leaderboard(@event.id)

    @leaderboard  = event.leaderboard
    @event_url    = "#{host_url}tours/#{@tour.id}/events/#{@event.id}"
    @tour_url     = "#{host_url}tours/#{@tour.id}"

    mail(to: user.email, subject: "#{@scorer.name} scored an event in #{@tour.name}" )
  end

  def role_changed(user, new_role, tour, changer)
    headers['X-Mailgun-Tag'] = "changed_role"
    @user   = user
    @tour   = tour
    @new_role = new_role
    @changer = changer

    @admin = new_role == :admin

    @url     = "#{host_url}tours/#{@tour.id}"

    what = new_role == :admin ? "made you admin" : "removed your admin rights"
    mail(to: user.email, subject: "#{@changer.name} #{what} in #{@tour.name}" )
  end

  def new_season(user, tour, sender)
    headers['X-Mailgun-Tag'] = "new_season"
    @tour   = tour
    @sender = sender

    @url  = "#{host_url}tours/#{@tour.id}"
    mail(to: user.email, subject: "#{@sender.name} created a new season in #{@tour.name}" )
  end

  private

  def host_url
    "https://simplegolftour.com/"
  end

end

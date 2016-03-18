class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  before_action :authenticate
  attr_accessor :current_user

  private

  def authenticate
    authenticate_token || render_unathorized
  end

  def authenticate_token
    authenticate_with_http_token do |token|
      @current_user = User.find_by(session_token: token)
    end
  end

  def render_unathorized
    @current_user = nil
    headers["WWW-Authenticate"] = "Token realm='Simple Golftour API'"
    render json: { error: "Bad credentials" }, status: 401
  end

  def track_event(event_name, data = {})
    TrackUserEventJob.new.async.perform(event_name, data)
  end
end

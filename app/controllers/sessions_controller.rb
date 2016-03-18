class SessionsController < ApplicationController
  include Sorcery::Controller

  def create
    user = login(params[:email], params[:password])
    if user
      track_event(:logged_in, {user_id: user.id})
      render json: { session_token: user.session_token }
    else
      render json: { error: 'Incorrect credentials' }, status: 401
    end
  end

  def destroy
    logout
    render json: { message: 'Logged out' }
  end


  def form_authenticity_token; end
end

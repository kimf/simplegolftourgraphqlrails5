class GraphqlController < ApplicationController
  before_action :set_current_user

  def create
    result = RelaySchema.execute(
      params[:query],
      debug: true,
      variables: params[:variables],
      context: {
        current_user: set_current_user
      }
    )
    render json: result
  end

  private

  def set_current_user
    nil
  end
end

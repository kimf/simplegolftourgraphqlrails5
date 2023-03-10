class QueriesController < ApplicationController
  # skip_before_action :authenticate
  # before_action :set_current_user

  def new
  end

  # def create_old
  #   query_string = params[:query]
  #   query_variables = params[:variables] || {}

  #   result = GraphQL::Schema.new(
  #     query: QueryType # mutation: MutationType
  #   ).execute(query_string, variables: query_variables)

  #   render json: result
  # end

  def create
    result = RelaySchema.execute(
      params[:query],
      variables: params[:variables],
      context: {
        current_user: current_user
      }
    )
    render json: result
  end
end

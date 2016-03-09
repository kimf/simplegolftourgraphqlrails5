Rails.application.routes.draw do
  # Serve websocket cable requests in-process
  # mount ActionCable.server => '/cable'

  scope "/graphql" do
    post "/", to: "graphql#create"
  end

  resources :queries
end

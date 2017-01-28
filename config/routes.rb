Rails.application.routes.draw do
  # Serve websocket cable requests in-process
  # mount ActionCable.server => '/cable'

  get "/graphiql", to: "graphiql#index"
  resources :queries, only: [:create]

  get "/api/players", to: "fake_api#players"
  get "/api/courses", to: "fake_api#courses"
  post "/api/authenticate", to: "fake_api#authenticate"

  resources :sessions, only: [:create, :destroy]
end

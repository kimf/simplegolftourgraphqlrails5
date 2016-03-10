Rails.application.routes.draw do
  # Serve websocket cable requests in-process
  # mount ActionCable.server => '/cable'

  get "/graphiql", to: "graphiql#index"
  resources :queries, only: [:create]
end

require 'sidekiq/web'

Rails.application.routes.draw do
  get 'settings/show'
  get 'api/index'
  resources :home, only: [:index]

  # resources :agents, controller: "bots", type: "Agent"

  resources :bots do
    member do
      post :promote
    end
  end

  resources :chats do
    collection do
      post :search
    end
    member do
      get :readonly
    end
  end

  resource :settings

  get "/tag/:q", to: "chats#tag", as: :tag
  get "/c/:id", to: "chats#readonly", as: :readonly

  get "/auth/:provider/callback", to: "sessions#create"
  get "/logout", to: "sessions#destroy", as: :logout

  post "/api", to: "api#index", as: :api

  # Defines the root path route ("/")
  root "home#index"

  # quick health check at /up
  get "/up", to: proc { [200, {}, ["OK"]] }

  mount Sidekiq::Web, at: '/sidekiq', constraints: AdminConstraint
end

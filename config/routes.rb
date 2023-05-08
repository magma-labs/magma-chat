require 'sidekiq/web'

Rails.application.routes.draw do
  resources :home, only: [:index]

  resources :bots, only: [:show]

  resources :conversations do
    collection do
      post :search
    end
    member do
      get :readonly
    end
  end

  resource :settings

  namespace :admin, constraints: AdminConstraint do
    resources :bots do
      member do
        post :promote
      end
    end
    resources :conversations
    resources :users
  end

  get "/tts/:message_id.mp3", to: "conversations#tts", as: :tts

  get "/tag/:q", to: "conversations#tag", as: :tag
  get "/c/:id", to: "conversations#readonly", as: :readonly

  get "/auth/:provider/callback", to: "sessions#create"
  get "/logout", to: "sessions#destroy", as: :logout

  get 'api/index'
  post "/api", to: "api#index", as: :api

  # Defines the root path route ("/")
  root "home#index"

  # quick health check at /up
  get "/up", to: proc { [200, {}, ["OK"]] }

  mount Sidekiq::Web, at: '/sidekiq', constraints: AdminConstraint
end

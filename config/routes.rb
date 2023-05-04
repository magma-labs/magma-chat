require 'sidekiq/web'

Rails.application.routes.draw do
  resources :home, only: [:index]

  resources :bots do
    member do
      get :observations
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

  namespace :admin, constraints: AdminConstraint do
    resources :bots do
      member do
        post :promote
      end
    end
    resources :chats
    resources :users
  end

  get "/tag/:q", to: "chats#tag", as: :tag
  get "/c/:id", to: "chats#readonly", as: :readonly

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

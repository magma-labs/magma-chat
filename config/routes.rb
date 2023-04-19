Rails.application.routes.draw do
  get 'api/index'
  resources :home, only: [:index]

  resources :bots

  resources :chats do
    collection do
      post :search
    end
    member do
      get :readonly
    end
  end

  get "/tag/:q", to: "chats#tag", as: :tag
  get "/c/:id", to: "chats#readonly", as: :readonly

  get "/auth/:provider/callback", to: "sessions#create"
  get "/logout", to: "sessions#destroy", as: :logout

  post "/api", to: "api#index", as: :api

  # Defines the root path route ("/")
  root "home#index"
end

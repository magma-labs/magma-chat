Rails.application.routes.draw do
  resources :home, only: [:index]

  resources :bots

  resources :chats do
    collection do
      post :search
    end
  end

  get "/tag/:q", to: "chats#tag", as: :tag

  get "/auth/:provider/callback", to: "sessions#create"
  get "/logout", to: "sessions#destroy", as: :logout

  # Defines the root path route ("/")
  root "home#index"
end

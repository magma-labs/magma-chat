Rails.application.routes.draw do
  resources :home, only: [:index]
  resources :chats

  get "/auth/:provider/callback", to: "sessions#create"
  get "/logout", to: "sessions#destroy", as: :logout

  # Defines the root path route ("/")
  root "home#index"
end

Rails.application.routes.draw do
  resources :home, only: [:index]
  resources :chats
  resource :example

  # Defines the root path route ("/")
  root "home#index"
end

Rails.application.routes.draw do
  resource :example, constraints: -> { Rails.env.development? }
  resources :home, only: [:index]

  # Defines the root path route ("/")
  root "home#index"
end

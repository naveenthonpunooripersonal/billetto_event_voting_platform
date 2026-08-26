Rails.application.routes.draw do
  root "events#index"

  resources :events, only: [ :index ] do
    resources :votes, only: [ :create ]
  end

  get "/sign-in", to: "sessions#new"
end

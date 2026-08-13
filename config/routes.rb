Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token
  resources :entries, only: %i[ index show new create ]
  get "feedback", to: "feedback#show", as: :feedback
  get "feed", to: "entries#index", defaults: { format: :rss }, as: :feed

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  root "entries#index"

  # Keep unknown public URLs inside the app chrome instead of exposing Rails'
  # development exception page on the NUC preview host.
  match "*unmatched_path", to: "errors#not_found", via: %i[ get head ]
end

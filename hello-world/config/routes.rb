Rails.application.routes.draw do
  get 'health_check/healthcheck'
  root "articles#index"

  get "/articles", to: "articles#index"
end

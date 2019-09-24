# frozen_string_literal: true

require 'sidekiq/web'

Rails.application.routes.draw do
  get '/card/new' => 'billings#new_card', as: :add_payment_method
  post '/card' => 'billings#create_card', as: :create_payment_method

  resources :plans, only: %i[show index]
  resources :subscription_first, only: %i[new edit create update]
  resources :billings, only: %i[new create]
  resources :charges, only: %i[new create]

  namespace :admin do
    resources :users
    resources :plans
    resources :subscriptions
    resources :donations, only: %i[index show]
  end

  resources :users, only: %i[show new edit update create destroy] do
    resource :streak, only: %i[show]
    resources :cards, only: %i[index destroy]
  end

  get '/login' => 'sessions#login'
  get '/signup' => 'sessions#signup'

  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    # Protect against timing attacks:
    # - See https://codahale.com/a-lesson-in-timing-attacks/
    # - See https://thisdata.com/blog/timing-attacks-against-string-comparison/
    # - Use & (do not use &&) so that it doesn't short circuit.
    # - Use digests to stop length information leaking (see also ActiveSupport::SecurityUtils.variable_size_secure_compare)
    ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(username), ::Digest::SHA256.hexdigest(ENV["SIDEKIQ_USERNAME"])) &
      ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(password), ::Digest::SHA256.hexdigest(ENV["SIDEKIQ_PASSWORD"]))
  end if Rails.env.production?

  mount Sidekiq::Web => '/sidekiq'

  root 'static_pages#home'
end

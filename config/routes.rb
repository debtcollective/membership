# frozen_string_literal: true

require 'sidekiq/web'
require 'sidekiq-scheduler/web'

Rails.application.routes.draw do
  get '/card/new' => 'billings#new_card', as: :add_payment_method
  post '/card' => 'billings#create_card', as: :create_payment_method

  resources :plans, only: %i[show index]
  resources :subscription_charges, only: %i[new edit create update]
  resources :billings, only: %i[new create]
  resources :charges, only: %i[new create]

  namespace :admin do
    get '/dashboard' => 'dashboard#index'
    resources :users
    resources :plans
    resources :subscriptions
    resources :donations, only: %i[index show]
  end

  resources :users, only: %i[show new edit update create destroy] do
    get '/subscription' => 'users#subscription', as: :current_subscription
    get '/donations' => 'users#donation_history', as: :latest_donations
    resource :streak, only: %i[show]
    resources :cards, only: %i[index destroy]
    resource :subscription, only: %i[destroy]
    resources :plan_changes, only: %i[index new create]
  end

  get '/login' => 'sessions#login'
  get '/signup' => 'sessions#signup'

  get '/admin' => redirect('/admin/users')

  if Rails.env.production?
    mount Sidekiq::Web => '/sidekiq', constraints: AdminConstraint.new(require_master: true)
  else
    mount Sidekiq::Web => '/sidekiq'
  end

  root 'static_pages#home'
end

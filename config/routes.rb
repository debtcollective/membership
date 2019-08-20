# frozen_string_literal: true

Rails.application.routes.draw do
  get '/card/new' => 'billings#new_card', as: :add_payment_method
  post '/card' => 'billings#create_card', as: :create_payment_method

  resources :plans, only: %i[show index]
  resources :subscription_first, only: %i[new edit create update]
  resources :billings, only: %i[new create]

  namespace :admin do
    resources :users
    resources :plans
    resources :subscriptions
  end

  resources :user, only: %i[show new edit update create destroy] do
    resources :cards, only: %i[index destroy]
  end

  root 'static_pages#home'
end

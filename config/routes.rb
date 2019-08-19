# frozen_string_literal: true

Rails.application.routes.draw do
  resources :plans, only: %i[show index]
  resources :users, only: %i[show new edit update create destroy]
  resources :subscription_first, only: %i[new edit create update]

  namespace :admin do
    resources :users
    resources :plans
    resources :subscriptions
  end

  root 'static_pages#home'
end

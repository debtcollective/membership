# frozen_string_literal: true

require "sidekiq/web"
require "sidekiq-scheduler/web"

Rails.application.routes.draw do
  get "/admin", to: redirect("/admin/dashboard")

  get "/users/current" => "users#current", :constraints => {format: "json"}

  resources :subscriptions, only: %i[create]
  resources :charges, only: %i[create]

  namespace :admin do
    get "/dashboard" => "dashboard#index"
    resources :users
    resources :plans
    resources :funds, except: %i[show]
    resources :subscriptions
    resources :donations, only: %i[index show]
  end

  resources :user_confirmations, only: %i[index create] do
    post "/confirm" => "user_confirmations#confirm", :on => :collection
  end

  if Rails.env.production?
    mount Sidekiq::Web => "/sidekiq",
          :constraints => AdminConstraint.new(require_master: true)
  else
    mount Sidekiq::Web => "/sidekiq"
  end

  root to: "application#redirect_to_home_page"
end

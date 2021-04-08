# frozen_string_literal: true

require "sidekiq/web"
require "sidekiq-scheduler/web"

Rails.application.routes.draw do
  get "/admin", to: redirect("/admin/dashboard")

  resources :users, only: [] do
    collection do
      get "/current" => "users#current", :constraints => {format: "json"}
    end
  end

  match "/profile" => "user_profiles#edit", :via => :get, :as => :user_profile
  match "/profile" => "user_profiles#update", :via => [:put, :patch]

  get "/thank-you" => "static_pages#thank_you"

  resources :subscriptions, only: %i[create]
  resources :charges, only: %i[new create], path: "donate", path_names: {new: ""}

  namespace :admin do
    get "/dashboard" => "dashboard#index"
    resources :users
    resources :funds, except: %i[show]
    resources :subscriptions
    resources :donations, only: %i[index show]
  end

  resources :user_confirmations, only: %i[index create] do
    collection do
      post "/confirm" => "user_confirmations#confirm"

      get "/confirm_email/:email_token" => "user_confirmations#confirm_email_token", :as => "confirm_email_token"
      post "/confirm_email" => "user_confirmations#confirm_email", :as => "confirm_email"
    end
  end

  get "/login" => "sessions#login"

  if Rails.env.production?
    mount Sidekiq::Web => "/sidekiq",
          :constraints => AdminConstraint.new(require_master: true)
  else
    mount Sidekiq::Web => "/sidekiq"
  end

  root to: "application#redirect_to_home_page"
end

# test routes for cypress
unless Rails.env.production?
  Rails.application.routes.append do
    match "/test/widget/donation" => "test_pages#widget_donation", :via => [:get]
    match "/test/widget/membership" => "test_pages#widget_membership", :via => [:get]
    scope path: "/__cypress__", controller: "cypress" do
      post "force_login", action: "force_login"
    end
  end
end

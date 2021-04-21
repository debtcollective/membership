# frozen_string_literal: true

require "sidekiq/web"
require "sidekiq-scheduler/web"

Rails.application.routes.draw do
  resources :users, only: [] do
    collection do
      get "/current" => "users#current", :constraints => {format: "json"}
    end
  end

  get "/thank-you" => "static_pages#thank_you"

  # User routes
  match "/profile" => "user_profiles#edit", :via => :get, :as => :user_profile
  match "/profile" => "user_profiles#update", :via => [:put, :patch]

  match "/membership" => "memberships#index", :via => :get, :as => :user_membership

  resources :subscriptions, only: %i[create]
  resources :charges, only: %i[new create], path: "donate", path_names: {new: ""}

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

  root to: "dashboard#index"
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

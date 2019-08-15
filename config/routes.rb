# frozen_string_literal: true

Rails.application.routes.draw do
  resources :plans, only: %i[show index]
  resources :users, only: %i[show new edit update create destroy]

  namespace :admin do
    resources :users, only: [:index]
  end

  root 'static_pages#home'
end

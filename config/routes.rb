# frozen_string_literal: true

Rails.application.routes.draw do
  resources :users, only: %i[show new edit update create destroy]
  root 'static_pages#home'
end

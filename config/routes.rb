Rails.application.routes.draw do

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  require 'sidekiq/web'

  constraint = lambda { |request| request.env["warden"].authenticate? and request.env['warden'].user }
  constraints constraint do
    mount Sidekiq::Web => '/sidekiq'
  end

  match '/widgets', to: 'widgets#index', via: [:get]

  match '/terms', to: 'welcome#terms', via: [:get]
  match '/privacy', to: 'welcome#privacy', via: [:get]
  match '/support', to: 'welcome#support', via: [:get]

  match '/canvas', to: 'canvas#index', via: [:get, :patch, :post]
  match '/canvas/edit', to: 'canvas#edit', via: [:get, :patch, :post]
  match '/giveaways/tab', to: 'giveaways#tab', via: [:get, :patch, :post]

  resources :likes, only: [:create]

  resources :facebook_pages, only: [:index, :show] do

    resources :giveaways do
      resources :entries, only: [:index, :create, :update]

      get :export_entries, on: :member
      get :active, on: :collection
      get :pending, on: :collection
      get :completed, on: :collection
      get :check_schedule, on: :collection
      get :clone, on: :member
      match :start, on: :member, via: [:get, :patch, :post]
      get :start_modal, on: :member
      get :end, on: :member
    end
  end

  match '/facebook_pages/:facebook_page_id/subscribe', to: 'subscriptions#create', as: 'facebook_page_subscribe', via: [:get, :post]

  match '/facebook_pages/:facebook_page_id/subscription_plans', to: 'subscription_plans#index', as: 'facebook_page_subscription_plans', via: [:get, :post]

  match '/users/:user_id/subscribe', to: 'subscriptions#create', as: 'user_subscribe', via: [:get, :post]

  match '/users/:user_id/unsubscribe', to: 'subscriptions#destroy', as: 'user_unsubscribe', via: [:get, :post]

  match '/users/:user_id/subscription_plans', to: 'subscription_plans#index', as: 'user_subscription_plans', via: [:get, :post]

  resources :users

  match '/deauth/:provider', to: 'users#deauth', via: [:get, :patch, :post]

  get '/dashboard', to: 'users#show', as: 'dashboard'

  match '/auth/:provider/callback', to: 'sessions#create', via: [:get, :post]
  match '/logout', to: 'sessions#destroy', via: [:get, :post]

  match '/:giveaway_id', to: 'giveaways#enter', as: 'enter', via: [:get, :patch, :post]

  root to: 'welcome#index'
end

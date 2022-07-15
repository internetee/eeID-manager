require 'constraints/administrator'
require 'sidekiq/web'
Rails.application.routes.draw do
  resources :services
  resources :contacts
  resources :authentications
  match 'api/v1/notify', via: :post, to: 'api/v1/notify#create'
  root to: 'dashboard#index'

  concern :auditable do
    resources :versions, only: :index
  end

  concern :searchable do
    collection do
      get 'search'
    end
  end

  match '/linkpay_callback', via: %i[get], to: 'linkpay#callback', as: :linkpay_callback

  match '/profile/toggle_subscription', via: :get, to: 'users#toggle_subscription',
                                        as: :user_toggle_sub

  namespace :eis_billing do
    put '/payment_status', to: 'payment_status#update', as: 'payment_status'
    put '/directo_response', to: 'directo_response#update', as: 'directo_response'
  end

  namespace :admin, constraints: Constraints::Administrator.new do
    mount Sidekiq::Web, at: 'sidekiq'
    resources :authentications, only: %i[index show]
    resources :services, only: %i[index show update download_service_file]
    get 'services/:id/download_config', to: 'services#download_service_file', as: 'download_service_file'
    resources :invoices, except: %i[new create destroy], concerns: %i[auditable searchable] do
      member do
        get 'download'
      end
    end
    resources :users, concerns: %i[auditable searchable]
  end

  namespace :admin do
    match '(*any)', to: redirect('/'), via: %i[get post]
  end

  devise_scope :user do
    get 'dashboard', to: 'dashboard#index'
    get 'me', to: 'users#show'
    resources :users, param: :uuid
    match '/auth/tara/callback', via: %i[get post], to: 'auth/tara#callback', as: :tara_callback
    match '/auth/tara/cancel', via: %i[get post delete], to: 'auth/tara#cancel',
                               as: :tara_cancel
    get '/auth/failure', to: 'auth/tara#cancel'
    match '/auth/tara/create', via: [:post], to: 'auth/tara#create', as: :tara_create
  end

  devise_for :users, path: 'sessions',
                     controllers: { confirmations: 'email_confirmations', sessions: 'auth/sessions' }

  post 'invoices', to: 'invoices#create', as: :new_top_up_invoice
  resources :invoices, only: %i[create show edit update index], param: :uuid do
    member do
      get 'download'
    end
  end

  resource :locale, only: :update
end

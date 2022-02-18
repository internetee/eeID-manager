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
  match 'profile/edit', via: :get, to: 'users#edit_authwall', as: :user_edit_authwall
  match '/profile/toggle_subscription', via: :get, to: 'users#toggle_subscription',
        as: :user_toggle_sub

  namespace :admin, constraints: Constraints::Administrator.new do
    mount Sidekiq::Web, at: 'sidekiq'
    resources :authentications, only: [:index, :show]
    resources :services, only: [:index, :show, :update, :download_service_file]
    get 'services/:id/download_config', to: 'services#download_service_file', as: 'download_service_file'
    resources :invoices, except: %i[new create destroy], concerns: %i[auditable searchable] do
      member do
        get 'download'
      end
    end
    resources :users, concerns: %i[auditable searchable]
  end

  devise_scope :user do
    get 'dashboard', to: 'dashboard#index'
    get 'me', to: 'users#show'
    resources :users, param: :uuid
    match '/auth/tara/callback', via: %i[get post], to: 'auth/tara#callback', as: :tara_callback
    match '/auth/tara/cancel', via: %i[get post delete], to: 'auth/tara#cancel',
                               as: :tara_cancel
    match '/auth/tara/create', via: [:post], to: 'auth/tara#create', as: :tara_create
  end

  devise_for :users, path: 'sessions',
                     controllers: { confirmations: 'email_confirmations', sessions: 'auth/sessions' }

  post 'invoices', to: 'invoices#create', as: :new_top_up_invoice
  resources :invoices, only: %i[create show edit update index], param: :uuid do
    member do
      get 'download'
    end

    resources :payment_orders, only: %i[new show create], shallow: true, param: :uuid do
      member do
        get 'return'
        put 'return'
        post 'return'

        post 'callback'
      end
    end
  end

  resource :locale, only: :update
end

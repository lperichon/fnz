Fnz::Application.routes.draw do
  #mount TzMagic::Engine => "/tz_magic"

  #authenticated :user do
  #  root :to => 'home#index'
  #end

  get "/login",  to: "sso_sessions#show"
  match '/logout', to: "sso_sessions#destroy", via: [:get, :delete]
  devise_for :users, :controllers => { :registrations => "registrations"}
  resource :sso_session

  resources :user_businesses
  resources :businesses do
    resources :month_tag_totals, only: [:index]
    resources :admparts do
      get "/ym/:year/:month", to: "admparts#show", as: :dated_admpart, on: :collection
      member do
        get :attendance_detail
      end
      collection do
        get :current, to: "admparts#show", id: :current
      end
    end
    resources :accounts do
      member do
        patch :update_balance
      end
      resources :transactions, :only => [:index] do
        get :stats, :on => :collection
      end
      resources :debits, :controller => 'transactions', :only => [:index]
      resources :credits, :controller => 'transactions', :only => [:index]
      resources :transfers, :controller => 'transactions', :only => [:index]
      resources :balance_checks
    end
    resources :recurrent_transactions
    resources :transactions do
      resources :transaction_spliters, only: [:new, :create] do
        collection do
          get :new_n_split
          post :create_n_split
        end
      end
      member do
        get :receipt
      end
      collection do
        get :batch_edit
        put :batch_update
        get :stats
      end
    end
    resources :debits, :controller => 'transactions', :only => [:index, :update]
    resources :credits, :controller => 'transactions', :only => [:index, :update]
    resources :transfers, :controller => 'transactions', :only => [:index, :update]
    resources :tags do
      collection do
        # required for Sortable GUI server side actions
        post :rebuild
      end
    end
    resources :month_exchange_rates do
      collection do
        get :get_rate
      end
      member do
        put :refresh_rate
      end
    end
    resources :transaction_rules
    resources :contacts
    resources :agents
    resources :products
    resources :sales do
      get :stats, :on => :collection
      resource :payment, :only => [:new, :create]
    end
    resources :payment_types
    resources :installments
    resource :payment, :only => [:new, :create]
    resources :memberships do
      resource :payment, :only => [:new, :create]
      resources :installments do
      	resource :payment, :only => [:new, :create]
      end
      resource :enrollment do
        resource :payment, :only => [:new, :create]
      end
      get :overview, :on => :collection
      get :stats, :on => :collection
      get :stats_detail, :on => :collection
    end
    resources :inscriptions do
      resources :transactions
    end
    resources :imports do
      put :process_csv, :on => :member
      get :errors, :on => :member
    end
    resources :users
    resources :closures
    resource :closure do
      get :print, :on => :member
    end
  end
  resources :debits, :controller => 'transactions', :except => [:index]
  resources :credits, :controller => 'transactions', :except => [:index]
  resources :transfers, :controller => 'transactions', :except => [:index]
  resources :custom_prizes

  resources :receipts
  get "/r/:id", to: "receipts#show"

  get 'messages', to: 'messages#catch_message'
  get 'sns', to: 'messages#sns'
  post 'sns', to: 'messages#sns'

  namespace 'admin' do
    resources :businesses, only: [:index, :show, :edit, :update, :destroy]
  end

  namespace 'api' do
    namespace 'v0' do
      resources :imports, only: [:create, :show] do
        member do
          get :failed_rows # GET /api/v0/imports/:id/failed_rows
        end
      end
      resources :businesses do
        resources :contacts do
          resource :current_membership
        end
	      get 'current_memberships', to: "current_memberships#index"
      end
      resources :merges, only: [:create]
      resources :inscriptions, only: [:create]
      namespace 'notifications' do
        post :mercadopago
      end
    end
  end

  root to: "home#index"
end

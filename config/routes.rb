Fnz::Application.routes.draw do
  mount TzMagic::Engine => "/tz_magic"

  authenticated :user do
    root :to => 'home#index'
  end
  root :to => "home#index"
  devise_for :users, :controllers => { :registrations => "registrations"}
  resources :businesses do
    resources :accounts do
      resources :transactions, :only => [:index] do
        get :stats, :on => :collection
      end
      resources :debits, :controller => 'transactions', :only => [:index]
      resources :credits, :controller => 'transactions', :only => [:index]
      resources :transfers, :controller => 'transactions', :only => [:index]
    end
    resources :transactions do
      get :stats, :on => :collection
    end
    resources :debits, :controller => 'transactions', :only => [:index]
    resources :credits, :controller => 'transactions', :only => [:index]
    resources :transfers, :controller => 'transactions', :only => [:index]
    resources :tags do
      collection do
        # required for Sortable GUI server side actions
        post :rebuild
      end
    end
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
    end
    resources :inscriptions
    resources :imports do
      put :process_csv, :on => :member
      get :errors, :on => :member
    end
    resources :users
  end
  resources :debits, :controller => 'transactions', :except => [:index]
  resources :credits, :controller => 'transactions', :except => [:index]
  resources :transfers, :controller => 'transactions', :except => [:index]

  match 'messages', to: 'messages#catch_message'

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
	match 'current_memberships', to: "current_memberships#index"
      end
      resources :merges, only: [:create]
    end
  end
end

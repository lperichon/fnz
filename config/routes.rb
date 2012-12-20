Fnz::Application.routes.draw do
  mount TzMagic::Engine => "/tz_magic"

  authenticated :user do
    root :to => 'home#index'
  end
  root :to => "home#index"
  devise_for :users, :controllers => { :registrations => "registrations" }
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
    resources :tags
    resources :contacts
    resources :agents
    resources :products
    resources :sales do
      get :stats, :on => :collection
    end
    resources :memberships do
      resources :installments
      resource :enrollment
      get :overview, :on => :collection
      get :stats, :on => :collection
    end
    resources :imports do
      put :process_csv, :on => :member
      get :errors, :on => :member
    end
    resources :users
  end
  resources :debits, :controller => 'transactions', :except => [:index]
  resources :credits, :controller => 'transactions', :except => [:index]
  resources :transfers, :controller => 'transactions', :except => [:index]
end

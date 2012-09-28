Fnz::Application.routes.draw do
  authenticated :user do
    root :to => 'home#index'
  end
  root :to => "home#index"
  devise_for :users
  resources :users, :only => [:show, :index]
  resources :businesses do
    resources :accounts do
      resources :transactions, :only => [:index]
      resources :debits, :controller => 'transactions', :only => [:index]
      resources :credits, :controller => 'transactions', :only => [:index]
      resources :transfers, :controller => 'transactions', :only => [:index]
    end
    resources :transactions
    resources :debits, :controller => 'transactions', :only => [:index]
    resources :credits, :controller => 'transactions', :only => [:index]
    resources :transfers, :controller => 'transactions', :only => [:index]
    resources :tags
    resources :contacts
    resources :agents
    resources :products
    resources :sales
    resources :memberships do
      resources :installments
      resource :enrollment
    end
    resources :imports
  end
  resources :debits, :controller => 'transactions', :except => [:index]
  resources :credits, :controller => 'transactions', :except => [:index]
  resources :transfers, :controller => 'transactions', :except => [:index]
end

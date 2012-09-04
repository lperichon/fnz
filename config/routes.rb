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
    resources :transactions, :only => [:index]
    resources :debits, :controller => 'transactions', :only => [:index]
    resources :credits, :controller => 'transactions', :only => [:index]
    resources :transfers, :controller => 'transactions', :only => [:index]
    resources :tags
    resources :contacts
    resources :agents
    resources :products
    resources :sales, :only => [:index]
  end
  resources :transactions, :except => [:index]
  resources :debits, :controller => 'transactions', :except => [:index]
  resources :credits, :controller => 'transactions', :except => [:index]
  resources :transfers, :controller => 'transactions', :except => [:index]
  resources :sales, :except => [:index]
end

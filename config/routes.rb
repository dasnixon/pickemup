Pickemup::Application.routes.draw do
  root to: 'home#index'
  scope :auth do
    get '/github/callback', to: 'sessions#github'
    get '/linkedin_oauth2/callback', to: 'sessions#linkedin'
    get '/stackexchange/callback', to: 'sessions#stackoverflow'
  end
  scope 'sessions', controller: :sessions do
    get :sign_in
    get :sign_up
  end
  scope '/', controller: :home do
    get :about
    get :contact
  end
  get "log_out" => "sessions#destroy", as: "log_out"
  resources :users, only: [] do
    member do
      get :resume
      get :skills
      get :preferences
      get :get_preference
      put :update_preference
    end
    resources :conversations
    resources :messages, except: [:edit, :update, :destroy]
  end
  resources :companies, except: [:new] do
    resources :conversations
    resources :messages, except: [:edit, :update, :destroy]
  end
  post "/company_log_in" => "sessions#company"
  resources :subscriptions, except: [:destroy] do
    member do
      get 'edit_card'
      post 'edit_card'
    end
  end
  match '/subscriptions_listener' => 'subscriptions#listener', :via => [ :post, :get ]
  require 'sidekiq/web'
  mount Sidekiq::Web, at: '/sidekiq'
end

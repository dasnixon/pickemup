Pickemup::Application.routes.draw do
  scope :auth do
    get '/github/callback', to: 'sessions#github'
    get '/linkedin_oauth2/callback', to: 'sessions#linkedin'
    get '/stackexchange/callback', to: 'sessions#stackoverflow'
  end
  scope '/', controller: :home do
    get :about
    get :contact
  end
  get "log_out" => "sessions#destroy", as: "log_out"
  resources :users, only: [:edit, :update] do
    member do
      get :resume
      get :skills
    end
  end
  resources :companies
  get "/company_log_in" => "sessions#company_sign_in", :as => "company_log_in"
  post "/company_log_in" => "sessions#company"
  get "companies/sign_up" => "companies#new", :as => "company_sign_up"
  resources :subscriptions, except: [:destroy] do
    member do
      get 'edit_card'
      post 'edit_card'
    end
  end
  match '/subscriptions_listener' => 'subscriptions#listener', :via => [ :post, :get ]
  require 'sidekiq/web'
  mount Sidekiq::Web, at: '/sidekiq'
  root 'home#index'
end

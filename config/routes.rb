Pickemup::Application.routes.draw do
  root to: 'home#index'
  scope :auth do
    get '/github/callback', to: 'sessions#github'
    get '/linkedin/callback', to: 'sessions#linkedin'
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
    resources :conversations do
      member do
        put :untrash
      end
    end
    resources :messages, except: [:edit, :update, :destroy]
  end
  get '/companies/validate_company', to: "companies#validate_company"
  resources :companies, except: [:new] do
    resources :conversations do
      member do
        put :untrash
      end
    end
    resources :tech_stacks do
      member do
        get :retrieve_tech_stack
        put :update_tech_stack
      end
    end
    resources :job_listings do
      member do
        get :retrieve_listing
        put :update_listing
        get :toggle_active
      end
    end
    resources :messages, except: [:edit, :update, :destroy]
    resources :subscriptions, except: [:destroy] do
      member do
        get :edit_card
        put :edit_card
      end
    end
  end
  post "/company_log_in" => "sessions#company"
  match '/subscriptions_listener' => 'subscriptions#listener', :via => [ :post, :get ]
  require 'sidekiq/web'
  mount Sidekiq::Web, at: '/sidekiq'
end

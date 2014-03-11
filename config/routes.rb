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
    get :pricing
    post :create_contact
    get :terms_of_service
    get :privacy_policy
    get :get_matches
    get :job_matches
    get :dev_matches
  end
  get "log_out" => "sessions#destroy", as: "log_out"
  resources :users, only: [:edit, :update] do
    member do
      get :listings
      get :resume
      get :skills
      get :preferences
      get :get_preference
      patch :update_preference
      patch :toggle_activation
    end
    resources :conversations, only: [:index, :show, :destroy, :update] do
      member do
        patch :untrash
      end
    end
    resources :messages, except: [:edit, :update, :destroy]
  end
  resources :companies, except: [:new] do
    collection do
      get '/validate_company', to: 'companies#validate_company', as: :validate_company
    end
    member do
      patch :toggle_activation
    end
    get :purchase_options, to: 'subscriptions#purchase_options'
    get :get_users
    resources :conversations, only: [:index, :show, :destroy, :update] do
      member do
        patch :untrash
      end
    end
    resources :tech_stacks, only: [:index, :new, :create, :edit, :destroy] do
      member do
        get :retrieve_tech_stack
        patch :update_tech_stack
      end
    end
    resources :job_listings do
      member do
        get :search_users
        get :retrieve_listing
        patch :update_listing
        patch :toggle_active
      end
      collection do
        get :guide
      end
    end
    resources :messages, except: [:edit, :update, :destroy]
    resources :subscriptions, except: [:destroy] do
      member do
        get :edit_card
        patch :edit_card
      end
    end
  end
  resources :interviews, except: [:edit, :update, :destroy] do
    collection do
      get :events
    end
    member do
      patch :accept_candidate
      patch :reject_candidate
      get :setup_user_reschedule
      patch :user_reschedule
      get :setup_company_reschedule
      patch :company_reschedule
      patch :accept_scheduled
      delete :user_cancel
      delete :company_cancel
    end
  end
  resources :admins, only: [:index]
  get "/admin/log_in" => "admins#sign_in"
  post "/admin/log_in" => "sessions#admin"
  post "/company_log_in" => "sessions#company"
  match '/subscriptions_listener' => 'subscriptions#listener', via: :all

  namespace :api do
    resource :auth, only: [] do
      collection do
        get :logged_in
      end
    end
  end

  require 'sidekiq/web'
  mount Sidekiq::Web, at: '/sidekiq'
  mount JasmineRails::Engine => "/specs" if defined?(JasmineRails)
end

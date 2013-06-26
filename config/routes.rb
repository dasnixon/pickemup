Pickemup::Application.routes.draw do
  scope :auth do
    get '/github/callback', to: 'users#create'
    get '/linkedin/callback', to: 'users#update'
  end

  root 'home#index'
end

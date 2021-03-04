Rails.application.routes.draw do
  resources :applications, only: [:index, :create, :show, :update], param: :token do
    resources :chats, only: [:index, :create, :show], param: :number do
      post 'search', to: 'messages#search'
      resources :messages, only: [:create, :index, :show, :update], param: :number
    end
  end
end

# require 'sidekiq/web'
# mount Sidekiq::Web => '/sidekiq'

# # Rails >= 5.2:
# Sidekiq::Web.set :session_secret, Rails.application.credentials[:secret_key_base]
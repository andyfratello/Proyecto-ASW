Rails.application.routes.draw do
  root 'microposts#index'
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions',
    omniauth_callbacks: 'users/omniauth_callbacks',
  }
  resources :microposts
  resources :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  get 'microposts/new', to: 'microposts#new', as: 'microposts_new'
  get 'microposts/:id', to: 'microposts#show'
  get 'likes_new', to: 'likes#create'
  delete 'microposts/:id/likes', to: 'likes#destroy'

  resources :microposts do
    resources :likes
  end

  # Defines the root path route ("/")
  # root "articles#index"
end

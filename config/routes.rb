Rails.application.routes.draw do
  resources :comments
  resources :microposts
  resources :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  get 'microposts/new', to: 'microposts#new', as: 'microposts_new'
  # Defines the root path route ("/")
  # root "articles#index"
  root 'microposts#index'
end

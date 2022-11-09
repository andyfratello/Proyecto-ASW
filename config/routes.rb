Rails.application.routes.draw do
  resources :replies
  resources :comment_likes
  get 'comments/new'
  get 'comments/create'
  resources :comments
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
  get 'microposts/:id/edit', to: 'microposts#show', as: 'microposts_edit'

  get 'microposts/:id', to: 'microposts#show'
  get 'likes_new', to: 'likes#create'
  delete 'microposts/:id/likes', to: 'likes#destroy'

  get '/users/upvoted_submissions/:id', to: 'users#submissions'
  get '/users/upvoted_comments/:id', to: 'users#upvoted_comments'
  get 'users/:id/comments', to:'users#comments'

  get 'comment_likes_new', to: 'comment_likes#create'
  delete 'comments/:id/comment_likes', to: 'comment_likes#destroy'

  get '/threads', to: 'users#comments', as: 'user_comments'

  get '/comments/:id/replies', to: 'comments#replies'

  resources :microposts do
    resources :likes
  end

  resources :microposts do
    resources :comments
  end

  resources :comments do
    resources :comment_likes
  end

  resources :comments do
    resources :replies
  end

  # Defines the root path route ("/")
  # root "articles#index"
end

Rails.application.routes.draw do

  root 'static_pages#top'
  get '/signup', to: 'users#new'
  
  # ログイン機能
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  resources :users do
    member do
      get 'edit_basic_info'
      patch 'update_basic_info'
      get 'attendances/edit_one_month'
      patch 'attendances/update_one_month'
      patch 'index_update'
    end
    collection { post :import }
    resources :attendances, only: :update
    collection { get :work_start_user_index }
  end
  
  # get '/bases', to: 'bases#index'
  resources :bases do
    post 'create'
    patch 'update'
  end
  
end

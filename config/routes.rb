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
      get 'one_month_check' # 上長お知らせ欄からの確認モーダルリンク
      patch 'attendances/one_month_reply', as: :one_month_reply # 1ヶ月申請の申請ステータスのみ上書き（承認）更新
      patch 'attendances/month_approval', as: :month_approval # 1ヶ月申請の申請ステータス・申請先（上長）・申請先のみ上書き更新
      get 'attendances/edit_one_month'
      patch 'attendances/edit_approval', as: :edit_approval # 勤怠変更申請の申請時間・申請ステータス・申請先（上長）のみ上書き更新
      get 'edit_attendance_check' # 上長お知らせ欄からの確認モーダルリンク
      patch 'attendances/edit_attendance_reply', as: :edit_attendance_reply # 1ヶ月申請の申請ステータスのみ上書き（承認）更新
      
      # patch 'attendances/update_one_month'
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

class UsersController < ApplicationController
  
  include SessionsHelper
  
  before_action :set_user, only: [:show, :edit, :update, :destroy, :edit_basic_info, :update_basic_info] # paramsハッシュからユーザーを取得
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy, :edit_basic_info, :update_basic_info] # ユーザーにログインを要求
  before_action :correct_user, only: [:edit, :update] # ユーザー自身のみが情報を編集・更新できる
  before_action :admin_user, only: [:destroy, :edit_basic_info, :update_basic_info] # システム管理権限所有かどうか判定
  before_action :set_one_month, only: :show
  
  def index
    if current_user.admin?
      @users = query.paginate(page: params[:page])
      store_location # index_update の redirect先一時保存【paginate対策】
    else
      flash[:danger] = '権限がありません。'
      redirect_to root_url
    end
    
    # パラメータとして名前のキーワードを受け取っている場合は絞って検索する
    # if params[:name].present?
    # @users = @users.get_by_name params[:name]
    # end
    
  end
  
  def index_update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params_index)
      flash[:success] = "ユーザー情報を更新しました。"
      # redirect_to users_url
      redirect_back_or users_url # index で記憶した redirect先(store_location)か 指定URLへ【paginate対策】
    else
      # render :index
      flash[:danger] = "無効な入力データがあった為、編集をキャンセルしました。"
      redirect_back_or users_url # index で記憶した redirect先(store_location)か 指定URLへ【paginate対策】
    end
  end
  
  def import
    # fileはtmpに自動で一時保存される
    User.import(params[:file])
    redirect_to users_url
  end
  
  def work_start_user_index
    @users = User.all.includes(:attendances)
  end
  
  def show
    # @worked_sum = @attendances.where.not(started_at: nil).count
    if current_user?(@user) || current_user.admin?
      @worked_sum = @attendances.where.not(started_at: nil).count
    else
      flash[:danger] = '権限がありません。'
      redirect_to root_url
    end
    
    # "app/controllers/application_controller.rb"の def set_one_month 内に移行
    
    # @first_day = Date.current.beginning_of_month
    # @last_day = @first_day.end_of_month
  end
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user # 保存成功後、ログインします。
      flash[:success] = '新規作成に成功しました。'
      redirect_to @user
    else
      render :new
    end
  end
  
  def edit
  end
  
  def update
    if @user.update_attributes(user_params)
      flash[:success] = "ユーザー情報を更新しました。"
      redirect_to @user
    else
      render :edit      
    end
  end
  
  def destroy
    @user.destroy
    flash[:success] = "#{@user.name}のデータを削除しました。"
    redirect_to users_url
  end
  
  def edit_basic_info
  end
  
  def update_basic_info
    if @user.update_attributes(basic_info_params)
      # 更新成功時の処理
      flash[:success] = "#{@user.name}の基本情報を更新しました。"
    else
      # 更新失敗時の処理
      flash[:danger] = "#{@user.name}の更新は失敗しました。<br>" + @user.errors.full_messages.join("<br>")
    end
    redirect_to users_url
  end
  
  private

    def user_params
      params.require(:user).permit(:name, :email, :department, :password, :password_confirmation)
    end
    
    def user_params_index
      params.require(:user).permit(:name, :email, :affiliation, :employee_number, :uid,:password, :basic_work_time, :designed_work_start_time, :designed_work_end_time)
    end
    
    def work_start_user
      (Date.current == day.worked_on) && day.started_at.present? && day.finished_at.nil?
    end
    
    def basic_info_params
    params.require(:user).permit(:department, :basic_time, :work_time)
    end
    
    def query
        if params[:user].present? && params[:user][:name]
          User.where('LOWER(name) LIKE ?', "%#{params[:user][:name].downcase}%")
        else
          User
        end
    end

end

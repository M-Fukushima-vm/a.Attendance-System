class UsersController < ApplicationController
  
  include SessionsHelper
  
  before_action :set_user, only: [:show, :edit, :update, :destroy, :edit_basic_info, :update_basic_info] # paramsハッシュからユーザーを取得
  before_action :logged_in_user, only: [:index, :show, :edit, :update, :destroy, :edit_basic_info, :update_basic_info] # ユーザーにログインを要求
  before_action :correct_user, only: [:edit, :update] # ユーザー自身のみが情報を編集・更新できる
  before_action :admin_user, only: [:destroy, :edit_basic_info, :update_basic_info] # システム管理権限所有かどうか判定
  before_action :set_one_month, only: :show
  before_action :notification_display, only: :show # お知らせの通知
  # before_action :user_class, only: :show
  
  def index
    if current_user.admin?
      # @users = query.paginate(page: params[:page])
      @users = query.where.not(id: current_user.id).order(:id).paginate(page: params[:page])
      store_location # index_update の redirect先一時保存【paginate対策】
    else
      # flash[:danger] = '権限がありません。'
      # redirect_to root_url
      redirect_to user_url(current_user.id)
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
    # if current_user?(@user) || current_user.admin? || current_user.superior? && !@user.admin?
    if current_user?(@user) || (current_user.superior? && !@user.admin?)
      @worked_sum = @attendances.where.not(started_at: nil).count
    else
      flash[:danger] = '権限がありません。'
      redirect_to root_url
    end
    
    superior_user_array #  application.controller ##↓↓↓　private ↓↓↓
    
    a_superior_user_array #  application.controller 
    
    one_month_apply_status # ↓↓↓　private ↓↓↓
      
    
    
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
    if current_user?(@user)

    else
      flash[:danger] = '権限がありません。'
      redirect_to user_url(current_user.id)
    end
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
      
  def one_month_check
    # #"申請中：１"かつ申請先がcurrent_user の レコード全て
    @one_month = Attendance.where(month_approval: 1).where(approval_superior: current_user.id)
    # 絞り込んだレコード群から「:user_id, :apply_month　の組み合わせの代表一つ」を選出
    @one_month_sort = @one_month.group(:user_id, :apply_month)
    @one_month_users = @one_month_sort.group_by{|u| u.user_id}
  end
  
  def edit_attendance_check
    # #"申請中：１"かつ申請先がcurrent_user の レコード全て
    @e_attendance = Attendance.where(edit_approval: 1).where(e_approval_superior: current_user.id)
    # 絞り込んだレコード群から「:user_id, :apply_month　の組み合わせの代表一つ」を選出
    @e_attendance_sort = @e_attendance.group(:user_id, :worked_on)
    @e_attendance_users = @e_attendance_sort.group_by{|u| u.user_id}
  end
  
  def overtime_attendance_check
    # #"申請中：１"かつ申請先がcurrent_user の レコード全て
    @o_attendance = Attendance.where(overtime_approval: 1).where(o_approval_superior: current_user.id)
    # 絞り込んだレコード群から「:user_id, :apply_month　の組み合わせの代表一つ」を選出
    @o_attendance_sort = @o_attendance.group(:user_id, :worked_on)
    @o_attendance_users = @o_attendance_sort.group_by{|u| u.user_id}
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
    
    def notification_display #申請の通知
      #1ヶ月申請の通知
      if Attendance.where(month_approval: 1).present?
        #"申請中：１"かつ申請先がcurrent_user の レコード全て
        @one_month = Attendance.where(month_approval: 1).where(approval_superior: current_user.id)
        #絞り込んだレコード群から「:user_id, :apply_month　の組み合わせ」をカウント
        @one_month_count = @one_month.pluck(:user_id, :apply_month).uniq.count
      end
      #勤怠変更申請の通知
      if Attendance.where(edit_approval: 1).present?
        #"申請中：１"かつ申請先がcurrent_user の レコード全て
        @e_attendance = Attendance.where(edit_approval: 1).where(e_approval_superior: current_user.id)
        #絞り込んだレコード群から「:user_id, :apply_month　の組み合わせ」をカウント
        @e_attendance_count = @e_attendance.pluck(:user_id, :worked_on).uniq.count
      end
      #残業申請の通知
      if Attendance.where(overtime_approval: 1).present?
        #"申請中：１"かつ申請先がcurrent_user の レコード全て
        @o_attendance = Attendance.where(overtime_approval: 1).where(o_approval_superior: current_user.id)
        #絞り込んだレコード群から「:user_id, :apply_month　の組み合わせ」をカウント
        @o_attendance_count = @o_attendance.pluck(:user_id, :worked_on).uniq.count
      end
    end
    
    # def superior_user_array #上長（申請先）選択
    #   @superior_user_array = [] #上長ユーザーの配列作成
    #   @superior_user = User.where(superior: true) #
    #   @superior_user = @superior_user.reject{|u| u == current_user} #上長のセルフ1ヶ月申請防止
    #     if User.where(superior: true).present?
    #       @superior_user_array = @superior_user
    #     end
    # end
    
    def one_month_apply_status
      if @u.present?
        @check_user = @u # u はモーダルitemのユーザー
      else 
        @check_user = @user
      end
      
      @first_day_status = Attendance.find_by(user_id: @user.id, worked_on: @first_day)
      @approval_superior = User.find_by(id: @first_day_status.approval_superior) #申請上長抽出
      
        if @approval_superior.present? && @first_day_status.month_approval == "承認" # 承認された場合（申請上長が抽出できて）
          @one_month_apply_status = "#{@approval_superior.name}から#{@first_day_status.month_approval}済"
        end
      
        if @approval_superior.present? && @first_day_status.month_approval == "否認" # 否認された場合（申請上長が抽出できて）
          @one_month_apply_status = "#{@approval_superior.name}から#{@first_day_status.month_approval}"
        end
      
        if @approval_superior.present? && @first_day_status.month_approval == "申請中" # 申請中の場合（申請上長が抽出できて）
          @one_month_apply_status = "#{@approval_superior.name}へ#{@first_day_status.month_approval}"
        end
      
      if !@first_day_status.approval_superior.present? || @first_day_status.month_approval == 0 # 未申請の場合
        @one_month_apply_status = "未申請"
      end
      
    end

    # def approved_user?(user)
    #   if user.admin? || (user == @user)
    #     # next
    #   elsif user.superior? && !@user.admin?
    #     # next
    #   # elsif logged_in?
    #     # next
    #   end
    # end
    
    # def user_class
    #   # if logged_in?
    #     redirect_to user_url(current_user) unless approved_user?(current_user)
    #   # else
    #   #   redirect_to root_url unless approved_user?(current_user)
    #   # end
    # end
    
end

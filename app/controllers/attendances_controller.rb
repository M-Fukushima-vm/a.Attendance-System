class AttendancesController < ApplicationController
  # 勤怠編集に通して良いレコードの絞り込みにヘルパーメソッドを利用します ⇨attendances_helper
  include AttendancesHelper
  
  before_action :set_user, only: [:edit_one_month, :update_one_month]
  before_action :logged_in_user, only: [:update, :edit_one_month]
  before_action :admin_or_correct_user, only: [:update, :edit_one_month, :update_one_month]
  before_action :set_one_month, only: :edit_one_month
  # before_action :superior_or_correct_user, only: :edit_one_month
  
  UPDATE_ERROR_MSG = "勤怠登録に失敗しました。やり直してください。"
  
  def update
    @user = User.find(params[:user_id])
    @attendance = Attendance.find(params[:id])
    # 出勤時間が未登録であることを判定します。
    if @attendance.started_at.nil?
      if @attendance.update_attributes(started_at: Time.current.change(sec: 0))
        flash[:info] = "おはようございます！"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    elsif @attendance.finished_at.nil?
      if @attendance.update_attributes(finished_at: Time.current.change(sec: 0))
        flash[:info] = "お疲れ様でした。"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    end
    redirect_to @user
  end

  def edit_one_month
    superior_user_array
  end

  def update_one_month
    ActiveRecord::Base.transaction do # トランザクションを開始します。
    
      attendances_update_valid? # 勤怠編集に許可する処理(除外する条件)を定義 　⇨ attendances_helper
      
      update_one_month_flash # update_one_month でのフラッシュ切り替え 　⇨ attendances_helper
      # flash[:success] = "1ヶ月分の勤怠情報を更新しました。"
      redirect_to user_url(date: params[:date])

    end
  rescue ActiveRecord::RecordInvalid # トランザクションによる例外処理の分岐です。
    flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。" # 例外が発生した時の処理
    redirect_to attendances_edit_one_month_user_url(date: params[:date])
  end
  
  # 1ヶ月申請の申請ステータス・申請先（上長）・申請先のみ上書き更新
  def month_approval
    if params[:user][:approval_superior].present?
      month_approval_params.each do |id, item|
        attendance = Attendance.find(id)
        attendance.approval_superior = params[:user][:approval_superior].to_i
        attendance.update_attributes(item)
      end
        flash[:success] = "当月勤怠を申請しました"
        redirect_to user_url(date: params[:date])
    else
      flash[:danger] = "申請上長を選択して下さい" 
      redirect_to user_url(date: params[:date])
    end
  end
  
  # 1ヶ月申請の申請ステータスのみ上書き（承認）更新
  def one_month_reply
    month_reply_params.each do |id, item|
      attendance = Attendance.find(id)
      if item[:must] == 0 #チェックボックスが未チェックの場合
        next #スキップ
      else
        attendance.update_attributes(item)
      end
    end
    flash[:success] = "変更確認チェックボックス☑の変更を送信しました"
    redirect_to user_url(date: params[:date])
  end
  
  def edit_approval
    edit_approval_params.each do |id, item|
      attendance = Attendance.find(id)
      item["t_started_at(1i)"] = attendance.worked_on.year.to_s
      item["t_started_at(2i)"] = attendance.worked_on.month.to_s
      item["t_started_at(3i)"] = attendance.worked_on.day.to_s
      item["t_finished_at(1i)"] = attendance.worked_on.year.to_s
      item["t_finished_at(2i)"] = attendance.worked_on.month.to_s
      item["t_finished_at(3i)"] = attendance.worked_on.day.to_s
      # debugger
      if item[:e_approval_superior].present? && item[:next_day] == "true"
        next_day = attendance.worked_on.day.to_i + 1
        item["t_finished_at(3i)"] = next_day.to_s
        attendance.update_attributes(item)
      elsif item[:e_approval_superior].present? && item[:next_day] == "false"
        # debugger
        attendance.update_attributes(item)
      end
    end
    redirect_to user_url(date: params[:date])
  end

  def edit_attendance_reply
    edit_attendance_reply_params.each do |id, item|
      # debugger
      attendance = Attendance.find(id)
      if item[:must].to_i == 0 #チェックボックスが未チェックの場合
        next #スキップ
      elsif item["edit_approval"] == "申請中" && item[:must].to_i == 1
        next
      elsif item["edit_approval"] == "未申請" && item[:must].to_i == 1
        attendance.edit_approval = "未申請"
        attendance.t_started_at = ""
        attendance.t_finished_at = ""
        attendance.next_day = false
        attendance.e_approval_superior = ""
        
        attendance.update_attributes(item)
      elsif item["edit_approval"] == "承認" && item[:must].to_i == 1
        attendance.edit_approval = "承認"
        attendance.started_at = attendance.t_started_at
        attendance.finished_at = attendance.t_finished_at
        attendance.t_started_at = ""
        attendance.t_finished_at = ""
        attendance.next_day = false
        attendance.e_approval_superior = ""
        
        attendance.update_attributes(item)
      elsif item["edit_approval"] == "否認" && item[:must].to_i == 1
        attendance.edit_approval = "否認"
        attendance.t_started_at = ""
        attendance.t_finished_at = ""
        attendance.next_day = false
        attendance.e_approval_superior = ""
        
        attendance.update_attributes(item)
      # else
      #   attendance.update_attributes(item)
      end
    end
    flash[:success] = "変更確認チェックボックス☑の変更を送信しました"
    redirect_to user_url(date: params[:date])
  end
  
  def overtime_apply
    superior_user_array
    @attendance = Attendance.find_by(user_id: params[:id], worked_on: params[:date])
  end
  
  def overtime_approval
    item = overtime_approval_params
    attendance = Attendance.find(item[:id])
    item["overtime(1i)"] = attendance.worked_on.year.to_s
    item["overtime(2i)"] = attendance.worked_on.month.to_s
    item["overtime(3i)"] = attendance.worked_on.day.to_s
    if item[:o_approval_superior].present? && item[:next_day] == "true"
      next_day = attendance.worked_on.day.to_i + 1
      item["overtime(3i)"] = next_day.to_s
      attendance.update_attributes(item)
      flash[:success] = "残業申請を送信しました"
      redirect_to user_url(current_user.id)
    elsif item[:o_approval_superior].present? && item[:next_day] == "false"
      attendance.update_attributes(item)
      flash[:success] = "残業申請を送信しました"
      redirect_to user_url(current_user.id)
    else
      redirect_to user_url(current_user.id)
    end
  end
  
  # 残業申請の申請ステータスのみ上書き（承認）更新
  def overtime_attendance_reply
    # debugger
    overtime_attendance_reply_params.each do |id, item|
      attendance = Attendance.find(id)
      if item[:must] == 0 #チェックボックスが未チェックの場合
        next #スキップ
      else
        attendance.update_attributes(item)
      end
    end
    flash[:success] = "変更確認チェックボックス☑の変更を送信しました"
    redirect_to user_url(date: params[:date])
  end
      
      
      # if item[:e_approval_superior].present? && item[:next_day] == 0
      #   attendance.update_attributes(item)
      #   flash[:success] = "勤怠編集を申請しました"
      #   redirect_to user_url(date: params[:date]) and return
      # elsif item[:e_approval_superior].present? && item[:next_day] == 1
      #   attendance.t_finished_at = item[t_finished_at(4i)] + 24
      #   attendance.update_attributes(item)
      #   flash[:success] = "勤怠編集を申請しました"
      #   redirect_to user_url(date: params[:date]) and return
      # else
      #   flash[:danger] = "申請上長を選択して下さい" 
      #   redirect_to attendances_edit_one_month_user_url(date: params[:date]) and return
      # end
    # end
        # flash[:success] = "勤怠編集を申請しました"
        # redirect_to user_url(date: params[:date]) and return
    # else
      # flash[:danger] = "申請上長を選択して下さい" 
      # redirect_to user_url(date: params[:date]) and return
    # end
    
    # if params[:user][:attendances][:e_approval_superior].present? && params[:user][:attendances][:next_day] == 1
    #   edit_approval_params.each do |id, item|
    #     attendance = Attendance.find(id)
    #     attendance.t_finished_at = params[:user][:t_finished_at] + 24
    #     attendance.update_attributes(item)
    #   end
    #     flash[:success] = "勤怠編集を申請しました"
    #     redirect_to user_url(date: params[:date]) and return
    # else
    #   flash[:danger] = "申請上長を選択して下さい" 
    #   redirect_to user_url(date: params[:date]) and return
    # end
  # end

  private
  
    # 1ヶ月分の勤怠情報を扱います。
    def attendances_params
      params.require(:user).permit(attendances: [:started_at, :finished_at, :note])[:attendances]
    end
    
    # beforeフィルター

    # 管理権限者、または現在ログインしているユーザーを許可します。
    def admin_or_correct_user
      @user = User.find(params[:user_id]) if @user.blank?
      unless current_user?(@user) || current_user.admin?
        flash[:danger] = "編集権限がありません。"
        redirect_to(root_url)
      end
    end
    
    # 上長、または現在ログインしているユーザーを許可します。
    # def superior_or_correct_user
    #   @user = User.find(params[:user_id]) if @user.blank?
    #   unless current_user?(@user) || current_user.superior?
    #     flash[:danger] = "編集権限がありません。"
    #     redirect_to(root_url)
    #   end
    # end
    
    # 1ヶ月申請の申請ステータス・申請先（上長）・申請先のみ上書き更新
    def month_approval_params
      params.permit(attendances:[:month_approval, :approval_superior, :apply_month])[:attendances]
    end
    
    # 1ヶ月申請の申請ステータスのみ上書き更新(:mustはモーダルのチェックボックスのパラメータ)=>attendance.rb
    def month_reply_params
      params.permit(attendances:[:month_approval, :must])[:attendances]
    end
    
    def edit_approval_params
      params.require(:user).permit(attendances:[:t_started_at, :t_finished_at, :next_day, :note, :e_approval_superior, :edit_approval])[:attendances]
    end
    
    def edit_attendance_reply_params
      params.permit(attendances:[:edit_approval, :must])[:attendances]
    end
    
    def overtime_approval_params
      params.permit(attendance:[:id, :overtime, :next_day, :gyoumu_syori, :o_approval_superior, :overtime_approval])[:attendance]
    end
    
    def overtime_attendance_reply_params
      params.permit(attendances:[:overtime_approval, :must])[:attendances]
    end

end

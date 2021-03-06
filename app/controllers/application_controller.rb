class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper
  
  $days_of_the_week = %w{日 月 火 水 木 金 土}
  
  # beforeフィルター

    # paramsハッシュからユーザーを取得します。
    def set_user
      @user = User.find(params[:id])
    end

    # ログイン済みのユーザーか確認します。
    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "ログインしてください。"
        redirect_to login_url
      end
    end
    
    # アクセスしたユーザーが現在ログインしているユーザーか確認します。
    def correct_user
      redirect_to(root_url) unless current_user?(@user)
    end
    
    # システム管理権限所有かどうか判定します。
    def admin_user
      redirect_to root_url unless current_user.admin?
    end
  
  # ページ出力前に1ヶ月分のデータの存在を確認・セットします。
  def set_one_month 
    @first_day = params[:date].nil? ?
    Date.current.beginning_of_month : params[:date].to_date
    @last_day = @first_day.end_of_month
    one_month = [*@first_day..@last_day] # 対象の月の日数を代入します。
    
    # ユーザーに紐付く一ヶ月分のレコードを検索し取得します。
    @attendances = @user.attendances.where(worked_on: @first_day..@last_day).order(:worked_on)

    unless one_month.count == @attendances.count # それぞれの件数（日数）が一致するか評価します。
      ActiveRecord::Base.transaction do # トランザクションを開始します。
      
        # 繰り返し処理により、1ヶ月分の勤怠データを生成します。
        one_month.each { |day| @user.attendances.create!(worked_on: day) }
      end
      @attendances = @user.attendances.where(worked_on: @first_day..@last_day).order(:worked_on)
    end

  rescue ActiveRecord::RecordInvalid # トランザクションによるエラーの分岐です。
    flash[:danger] = "ページ情報の取得に失敗しました、再アクセスしてください。"
    redirect_to root_url

  end
  
  def superior_user_array #上長（申請先）選択
    @superior_user_array = [] #上長ユーザーの配列作成
    @superior_user = User.where(superior: true, admin: false) #
    @superior_user = @superior_user.order(:id).reject{|u| u == current_user} #上長のセルフ1ヶ月申請防止
      if User.where(superior: true).present?
        @superior_user_array = @superior_user
      end
  end
  
  def a_superior_user_array #上長（申請先）選択
    @a_superior_user_array = [] #上長ユーザーの配列作成
    @a_superior_user = User.where(admin: true) #
    @a_superior_user = @a_superior_user.order(:id).reject{|u| u == current_user} #上長のセルフ1ヶ月申請防止
      if User.where(admin: true).present?
        @a_superior_user_array = @a_superior_user
      end
  end
  
  # # ページ出力前に1ヶ月分のログレコードの存在を確認・セットします。
  # def set_one_month_log 
  #   @first_day = params[:date].nil? ?
  #   Date.current.beginning_of_month : params[:date].to_date
  #   @last_day = @first_day.end_of_month
  #   l_one_month = [*@first_day..@last_day] # 対象の月の日数を代入します。
    
  #   # (before_actionの :set_user, :set_one_month で取得可能な)
  #   # ユーザー勤怠に紐付く一ヶ月分のログレコードを検索し取得します。
  #   @one_month_logs = Log.where(user_id: params[:id], hiduke: @first_day..@last_day).order(:hiduke)

  #   unless l_one_month.count <= @one_month_logs.count # それぞれの件数（日数）が一致するか評価します。
  #     # （対象月の日数以上のログレコード数）でない場合
  #     ActiveRecord::Base.transaction do # トランザクションを開始します。
      
  #       # 繰り返し処理により、1ヶ月分のログレコードを生成します。
  #       @attendances.each { |a| Log.create!(attendance_id: a.id, user_id: a.user_id, hiduke: a.worked_on) }
  #     end
  #     # @one_month_logs = Log.where(hiduke: @first_day..@last_day).order(:hiduke)
  #     @one_month_logs = Log.where(user_id: params[:id], hiduke: @first_day..@last_day).order(:hiduke)
  #   end

  # rescue ActiveRecord::RecordInvalid # トランザクションによるエラーの分岐です。
  #   flash[:danger] = "ページ情報の取得に失敗しました、再アクセスしてください。"
  #   redirect_to user_url(current_user.id)

  # end

end
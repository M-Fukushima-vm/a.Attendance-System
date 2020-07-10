module AttendancesHelper
  
  def attendance_state(attendance)
    # 受け取ったAttendanceオブジェクトが当日と一致するか評価します。
    if Date.current == attendance.worked_on
      return '出社' if attendance.started_at.nil?
      return '退社' if attendance.started_at.present? && attendance.finished_at.nil?
    end
    # どれにも当てはまらなかった場合はfalseを返します。
    false
  end
  
  # 出勤時間と退勤時間を受け取り、在社時間を計算して返します。
  def working_times(start, finish)
    format("%.2f", (((finish - start) / 60) / 60.0))
  end
  
  $error_flash_message = ''
  $error_flash_part = ''
  
  # 勤怠編集に許可する処理(除外する条件)を定義
  def attendances_update_valid?
    attendances_params.each do |id, item| # データベースの操作を保障したい処理
    attendance = Attendance.find(id)

    # スキップする条件を next
    
      # 【勤務履歴の捏造不可】
      if attendance[:started_at].blank? && attendance[:finished_at].blank? && (item[:started_at].present? || item[:finished_at].present?)
        $error_flash_message << "・勤務履歴のない日への出退社時間の入力<br>"
        $error_flash_part << "・#{attendance.worked_on.strftime("%m/%d")}<br>"
        next
      
      # 【勤務履歴の抹消不可】
      elsif attendance[:started_at].present? && attendance[:finished_at].present? && (item[:started_at].blank? || item[:finished_at].blank?)
        $error_flash_message << "・勤務履歴のある日の出退社時間の削除<br>"
        $error_flash_part << "・#{attendance.worked_on.strftime("%m/%d")}<br>"
        next

      # 【時間の関係性の逆転した登録不可】
      elsif item[:started_at].present? && item[:finished_at].present? && (item[:started_at] > item[:finished_at])
        $error_flash_message << "・時間の関係性の逆転した登録<br>"
        $error_flash_part << "・#{attendance.worked_on.strftime("%m/%d")}<br>"
        next
      
      # 【出社履歴の抹消不可】
      elsif attendance[:started_at].present? && item[:started_at].blank?
        $error_flash_message << "・出社履歴の削除<br>"
        $error_flash_part << "・#{attendance.worked_on.strftime("%m/%d")}<br>"
        next
        
      end
    # 上記スキップ条件に引っかからなかったレコードのみ更新
        attendance.update_attributes!(item)
    end
  end
  
  # update_one_month でのフラッシュ切り替え
  def update_one_month_flash
    if $error_flash_message.present?
      $error_flash_message << "【上記の許可されていない勤怠編集、誤入力の可能性が見つかりました。】<br>"
      flash[:danger] = $error_flash_message
      flash[:danger] = $error_flash_part
      flash[:info] = "該当しない日にちの編集内容のみ更新しました。"
      $error_flash_message = ''
      $error_flash_part = ''
    elsif
      flash[:success] = "1ヶ月分の勤怠編集内容を更新しました。"
    end
  end
  
  def edit_approval_valid?
    edit_approval_params.each do |id, item|
      attendance = Attendance.find(id)
      item["t_started_at(1i)"] = attendance.worked_on.year.to_s
      item["t_started_at(2i)"] = attendance.worked_on.month.to_s
      item["t_started_at(3i)"] = attendance.worked_on.day.to_s
      item["t_finished_at(1i)"] = attendance.worked_on.year.to_s
      item["t_finished_at(2i)"] = attendance.worked_on.month.to_s
      item["t_finished_at(3i)"] = attendance.worked_on.day.to_s
      # shaped_params = []
      # shaped_params << item
        hen_syu = "#{item["t_started_at(1i)"]}-#{item["t_started_at(2i)"]}-#{item["t_started_at(3i)"]} #{item["t_started_at(4i)"]}:#{item["t_started_at(5i)"]}"
        hen_tai = "#{item["t_finished_at(1i)"]}-#{item["t_finished_at(2i)"]}-#{item["t_finished_at(3i)"]} #{item["t_finished_at(4i)"]}:#{item["t_finished_at(5i)"]}"
      # debugger
      
      # スキップする条件を next
    
      # # 【勤務履歴の捏造不可】
      # if attendance[:started_at].blank? && attendance[:finished_at].blank? && (item[:started_at].present? || item[:finished_at].present?)
      #   $error_flash_message << "・勤務履歴のない日への出退社時間の入力<br>"
      #   $error_flash_part << "・#{attendance.worked_on.strftime("%m/%d")}<br>"
      #   next
      
      # 【勤務履歴の抹消不可】
      if item[:e_approval_superior].present? && attendance[:finished_at].present? && attendance[:finished_at].present? && 
        (item["t_started_at(4i)"].blank? || item["t_started_at(5i)"].blank? || item["t_finished_at(4i)"].blank? || item["t_finished_at(5i)"].blank?)
        $error_flash_message << "　・勤務実績（出退社時間）の削除にあたる編集申請<br>"
        $error_flash_part << "　・#{attendance.worked_on.strftime("%m/%d")}<br>"
        next
        
      # 【出社履歴の抹消不可】
      elsif item[:e_approval_superior].present? && attendance[:started_at].present? && 
        (item["t_started_at(4i)"].blank? || item["t_started_at(5i)"].blank?)
        $error_flash_message << "　・出社実績（出社時間）の削除にあたる編集申請<br>"
        $error_flash_part << "　・#{attendance.worked_on.strftime("%m/%d")}<br>"
        next

      # 【時間の関係性の逆転した登録不可】
      elsif item[:e_approval_superior].present? && 
        (item["t_started_at(4i)"].present? && item["t_started_at(5i)"].present?) && 
        (item["t_finished_at(4i)"].present? && item["t_finished_at(5i)"].present?) && (hen_syu.to_time.to_i > hen_tai.to_time.to_i)
        $error_flash_message << "　・時間の関係性の逆転した編集申請<br>"
        $error_flash_part << "　・#{attendance.worked_on.strftime("%m/%d")}<br>"
        next
      
      # 【退社時間のみの無効データへの変更不可】
      elsif item[:e_approval_superior].present? && 
        (item["t_started_at(4i)"].blank? || item["t_started_at(5i)"].blank?) && 
        (item["t_finished_at(4i)"].present? && item["t_finished_at(5i)"].present?)
        $error_flash_message << "　・編集出社時間の入力漏れ<br>"
        $error_flash_part << "　・#{attendance.worked_on.strftime("%m/%d")}<br>"
        next
        
      # 【出社時間のみの無効データへの変更不可】
      elsif item[:e_approval_superior].present? && 
        (item["t_started_at(4i)"].present? && item["t_started_at(5i)"].present?) && 
        (item["t_finished_at(4i)"].blank? || item["t_finished_at(5i)"].blank?)
        $error_flash_message << "　・編集退社時間の入力漏れ<br>"
        $error_flash_part << "　・#{attendance.worked_on.strftime("%m/%d")}<br>"
        next
        
      end
      
      if item[:e_approval_superior].present? && item[:next_day] == "true" && 
        (item["t_started_at(4i)"].present? && item["t_started_at(5i)"].present?) && 
        (item["t_finished_at(4i)"].present? && item["t_finished_at(5i)"].present?)
        next_day = attendance.worked_on.day.to_i + 1
        item["t_finished_at(3i)"] = next_day.to_s
        attendance.update_attributes(item)
      elsif item[:e_approval_superior].present? && item[:next_day] == "false" && 
        (item["t_started_at(4i)"].present? && item["t_started_at(5i)"].present?) && 
        (item["t_finished_at(4i)"].present? && item["t_finished_at(5i)"].present?)
        # debugger
        attendance.update_attributes(item)
      end
    end
    # flash[:success] = "編集申請を送信しました"
    redirect_to user_url(date: params[:date])
  end
  
  # edit_approval でのフラッシュ切り替え
  def edit_approval_flash
    if $error_flash_message.present?
      $error_flash_message << "【上記の許可されていない勤怠編集、誤入力が見つかりました。】<br>"
      $error_flash_message << $error_flash_part
      flash[:danger] = $error_flash_message
      flash[:info] = "該当しない日付の編集内容のみ申請しました。"
      $error_flash_message = ''
      $error_flash_part = ''
    elsif
      flash[:success] = "1ヶ月分の勤怠編集を申請しました。"
    end
  end
  
end

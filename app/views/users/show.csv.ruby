require 'csv'

CSV.generate do |csv|
  column_names = %w(日付 出社 退社 備考)
  csv << column_names
  @attendances.each do |attendance|
    column_values = [
      attendance.worked_on.present? ?
        attendance.worked_on.strftime("%m/%d") : "",
      attendance.started_at.present? ?
        attendance.started_at.strftime("%H:%M") : "",
      attendance.finished_at.present? ?
        attendance.finished_at.strftime("%H:%M") : "",
      attendance.note.present? ?
        attendance.note : ""
    ]
    csv << column_values
  end
end
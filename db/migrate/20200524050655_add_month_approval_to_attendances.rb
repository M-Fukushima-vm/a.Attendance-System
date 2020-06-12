class AddMonthApprovalToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :month_approval, :integer, null: false, default: 0
    add_column :attendances, :approval_superior, :integer
    add_column :attendances, :apply_month, :integer
  end
end

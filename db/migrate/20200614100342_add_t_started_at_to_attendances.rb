class AddTStartedAtToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :t_started_at, :datetime
    add_column :attendances, :t_finished_at, :datetime
    add_column :attendances, :next_day, :boolean, default: false
    add_column :attendances, :edit_approval, :integer, null: false, default: 0
    add_column :attendances, :e_approval_superior, :integer
  end
end

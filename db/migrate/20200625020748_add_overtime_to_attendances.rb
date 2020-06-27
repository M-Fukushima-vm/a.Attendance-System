class AddOvertimeToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :overtime, :datetime
    add_column :attendances, :overtime_approval, :integer, null: false, default: 0
    add_column :attendances, :o_approval_superior, :integer
    add_column :attendances, :gyoumu_syori, :string
    add_column :attendances, :sonohi_teiji, :datetime
  end
end

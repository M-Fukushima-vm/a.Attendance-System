class AddDetailsToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :affiliation, :string
    add_column :users, :employee_number, :integer
    add_column :users, :uid, :integer
    add_column :users, :basic_work_time, :datetime
    add_column :users, :designed_work_start_time, :datetime
    add_column :users, :designed_work_end_time, :datetime
    add_column :users, :superior, :boolean, default: false
  end
end

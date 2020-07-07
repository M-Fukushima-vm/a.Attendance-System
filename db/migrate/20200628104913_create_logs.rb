class CreateLogs < ActiveRecord::Migration[5.1]
  def change
    create_table :logs do |t|
      t.date :hiduke
      t.datetime :b_started_at
      t.datetime :b_finished_at
      t.datetime :started_at
      t.datetime :finished_at
      t.datetime :syouninbi
      t.integer :jyoucyou
      t.references :attendance, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end

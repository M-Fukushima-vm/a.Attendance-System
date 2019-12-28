class RenameTypeToColumnToAssortment < ActiveRecord::Migration[5.1]
  def change
    rename_column :bases, :type, :assortment
  end
end

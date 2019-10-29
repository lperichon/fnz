class DefaultAccount < ActiveRecord::Migration
  def change
    add_column :accounts, :default, :boolean
  end
end

class AddDrcUidToUsers < ActiveRecord::Migration
  def change
    add_column :users, :drc_uid, :string
  end
end

class ExternalIdString < ActiveRecord::Migration
  def change
    change_column :memberships, :external_id, :string
  end
end

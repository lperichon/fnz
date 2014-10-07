class AddMembreshipName < ActiveRecord::Migration
  def change
    add_column :memberships, :name, :string
  end
end

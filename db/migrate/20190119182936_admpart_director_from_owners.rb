class AdmpartDirectorFromOwners < ActiveRecord::Migration
  def change
    add_column :admparts, :dir_from_owners_aft_expses_percentage, :integer
  end
end

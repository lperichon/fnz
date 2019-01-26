class MultipleAdmpart < ActiveRecord::Migration
  def change
    add_column :admparts, :ref_date, :date
  end
end

class AddMonthlyDueDayToMemberships < ActiveRecord::Migration
  def change
    add_column :memberships, :monthly_due_day, :integer
  end
end

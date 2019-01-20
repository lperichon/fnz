class AdmpartInstallmentCriteria < ActiveRecord::Migration
  def change
    add_column :admparts, :agent_installments_attendance_percentage, :integer
  end
end

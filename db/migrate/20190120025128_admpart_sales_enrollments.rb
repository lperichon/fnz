class AdmpartSalesEnrollments < ActiveRecord::Migration
  def change
    add_column :admparts, :agent_sale_percentage, :integer
    add_column :admparts, :agent_enrollment_income_percentage, :integer
    add_column :admparts, :agent_enrollment_quantity_fixed_amount, :integer
  end
end

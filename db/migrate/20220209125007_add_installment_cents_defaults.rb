class AddInstallmentCentsDefaults < ActiveRecord::Migration
  def change
    change_column_default :installments, :balance_cents, 0
    change_column_default :installments, :value_cents, 0
  end
end

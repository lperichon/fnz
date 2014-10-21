class AddInstallmentObservatios < ActiveRecord::Migration
  def change
    add_column :installments, :observations, :string
  end
end

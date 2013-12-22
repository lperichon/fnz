class CreateInstallmentImportsInstallments < ActiveRecord::Migration
  def change
    create_table :installment_imports_installments do |t|
      t.references :installment_import
      t.references :installment
    end
  end
end

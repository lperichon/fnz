class CreateInstallments < ActiveRecord::Migration
  def change
    create_table :installments do |t|
      t.references :membership
      t.date :due_on
    end
  end
end

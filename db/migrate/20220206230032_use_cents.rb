class UseCents < ActiveRecord::Migration
  def change
    add_column :accounts, :balance_cents, :integer
    Account.update_all("balance_cents = balance*100")
    rename_column :accounts, :balance, :old_balance

    add_column :transactions, :amount_cents, :integer
    Transaction.update_all("amount_cents = amount*100")
    rename_column :transactions, :amount, :old_amount

    add_column :month_tag_totals, :total_amount_cents, :integer
    MonthTagTotal.update_all("total_amount_cents = total_amount*100")
    rename_column :month_tag_totals, :total_amount, :old_total_amount

    add_column :recurrent_transactions, :amount_cents, :integer
    RecurrentTransaction.update_all("amount_cents = amount*100")
    rename_column :recurrent_transactions, :amount, :old_amount

    add_column :installments, :value_cents, :integer
    Installment.update_all("value_cents = value*100")
    rename_column :installments, :value, :old_value

    add_column :installments, :balance_cents, :integer
    Installment.update_all("balance_cents = balance*100")
    rename_column :installments, :balance, :old_balance

    add_column :memberships, :value_cents, :integer
    Membership.update_all("value_cents = value*100")
    rename_column :memberships, :value, :old_value
  end
end

class RemoveNullConstraint < ActiveRecord::Migration
  def change
    change_column_null :accounts, :old_balance, true
    change_column_null :transactions, :old_amount, true
    change_column_null :month_tag_totals, :old_total_amount, true
    change_column_null :recurrent_transactions, :old_amount, true
    change_column_null :installments, :old_value, true
    change_column_null :installments, :old_balance, true
    change_column_null :memberships, :old_value, true
  end
end

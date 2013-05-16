class MembershipHasAPaymentType < ActiveRecord::Migration
  def change
    add_column :memberships, :payment_type_id, :integer
  end
end

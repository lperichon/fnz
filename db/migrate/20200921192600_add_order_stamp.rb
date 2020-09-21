class AddOrderStamp < ActiveRecord::Migration
  def change
    add_column :transactions, :order_stamp, :datetime
  end
end


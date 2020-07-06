class AddMonthTotalCurrency < ActiveRecord::Migration
  def change
    add_column :month_tag_totals, :currency, :string
  end
end

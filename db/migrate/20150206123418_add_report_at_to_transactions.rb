class AddReportAtToTransactions < ActiveRecord::Migration
  def change
    add_column :transactions, :report_at, :date
  end
end

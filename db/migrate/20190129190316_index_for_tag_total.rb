class IndexForTagTotal < ActiveRecord::Migration
  def change
    remove_index :transactions, [:business_id, :admpart_tag_id]
    add_index :transactions, [:business_id, :admpart_tag_id, :report_at], name: :tag_transactions_index
  end
end

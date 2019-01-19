class IndexTaggings < ActiveRecord::Migration
  def change
    add_index :taggings, [:tag_id, :transaction_id]
  end
end

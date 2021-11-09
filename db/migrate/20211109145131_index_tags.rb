class IndexTags < ActiveRecord::Migration
  def change
    add_index :tags, :rgt
    add_index :tags, :lft
    add_index :tags, :parent_id
    add_index :tags, :depth
  end
end

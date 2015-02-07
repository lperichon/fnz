class AddNestedToTags < ActiveRecord::Migration
  def change
  	add_column :tags, :parent_id, :integer # Comment this line if your project already has this column
    # Category.where(parent_id: 0).update_all(parent_id: nil) # Uncomment this line if your project already has :parent_id
    add_column :tags, :lft,       :integer
    add_column :tags, :rgt,       :integer

    # optional fields
    add_column :tags, :depth,          :integer
    add_column :tags, :children_count, :integer
  end
end

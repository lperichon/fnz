class SystemTags < ActiveRecord::Migration
  def change
    add_column :tags, :system_name, :string
  end
end

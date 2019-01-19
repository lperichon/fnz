class TagSection < ActiveRecord::Migration
  def change
    add_column :tags, :admpart_section, :string
  end
end

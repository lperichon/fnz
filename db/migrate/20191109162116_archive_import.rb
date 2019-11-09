class ArchiveImport < ActiveRecord::Migration
  def change
    add_column :imports, :archived, :boolean
  end
end

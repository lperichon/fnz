class CreateImports < ActiveRecord::Migration
  def change
    create_table(:imports) do |t|
      t.references :business
      t.attachment :upload

      t.timestamps
    end
  end
end

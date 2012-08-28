class CreateTags < ActiveRecord::Migration
  def change
    create_table(:tags) do |t|
      t.string :keyword,              :null => false, :default => ""
      t.references :business
    end
  end
end

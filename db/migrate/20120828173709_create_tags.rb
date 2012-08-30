class CreateTags < ActiveRecord::Migration
  def change
    create_table(:tags) do |t|
      t.string :name,              :null => false, :default => ""
      t.references :business
    end
  end
end

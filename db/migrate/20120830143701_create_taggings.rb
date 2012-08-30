class CreateTaggings < ActiveRecord::Migration
  def change
    create_table(:taggings) do |t|
      t.references :transaction
      t.references :tag
    end
  end
end

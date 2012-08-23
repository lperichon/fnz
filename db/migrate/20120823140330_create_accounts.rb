class CreateAccounts < ActiveRecord::Migration
  def change
    create_table(:accounts) do |t|
      t.string :name,              :null => false, :default => ""
      t.references :business
    end
  end
end

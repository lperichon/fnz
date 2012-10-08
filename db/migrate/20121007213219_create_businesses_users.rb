class CreateBusinessesUsers < ActiveRecord::Migration
  def change
    create_table :businesses_users do |t|
      t.references :business
      t.references :user
    end
  end
end

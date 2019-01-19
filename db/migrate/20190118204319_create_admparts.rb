class CreateAdmparts < ActiveRecord::Migration
  def change
    create_table :admparts do |t|
      t.integer :business_id

      t.timestamps
    end

    add_index :admparts, :business_id
  end
end

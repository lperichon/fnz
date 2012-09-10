class CreateMemberships < ActiveRecord::Migration
  def change
    create_table :memberships do |t|
      t.references :business
      t.references :contact
      t.date :begins_on
      t.date :ends_on
    end
  end
end

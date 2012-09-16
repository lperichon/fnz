class CreateEnrollments < ActiveRecord::Migration
  def change
    create_table :enrollments do |t|
      t.references :membership
      t.decimal :value, :null => false, :precision => 8, :scale => 2, :default => 0
    end
  end
end

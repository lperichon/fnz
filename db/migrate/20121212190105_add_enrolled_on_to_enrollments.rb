class AddEnrolledOnToEnrollments < ActiveRecord::Migration
  def change
    add_column :enrollments, :enrolled_on, :date
  end
end

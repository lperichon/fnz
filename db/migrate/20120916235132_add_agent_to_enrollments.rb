class AddAgentToEnrollments < ActiveRecord::Migration
  def change
    add_column :enrollments, :agent_id, :integer
  end
end

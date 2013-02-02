class AddPadmaTeacherToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :padma_teacher, :string
  end
end

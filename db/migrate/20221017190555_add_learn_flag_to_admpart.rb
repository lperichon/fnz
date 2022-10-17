class AddLearnFlagToAdmpart < ActiveRecord::Migration
  def change
    add_column :admparts, :use_learn_checkins, :boolean
  end
end

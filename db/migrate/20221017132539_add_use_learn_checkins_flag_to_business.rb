class AddUseLearnCheckinsFlagToBusiness < ActiveRecord::Migration
  def change
    add_column :businesses, :use_learn_checkins, :boolean
  end
end

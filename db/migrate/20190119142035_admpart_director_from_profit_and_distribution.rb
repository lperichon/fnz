class AdmpartDirectorFromProfitAndDistribution < ActiveRecord::Migration
  def change
    add_column :admparts, :director_from_profit_percentage, :integer
    add_column :admparts, :owners_percentage, :integer
  end
end

class CreateAgents < ActiveRecord::Migration
  def change
    create_table :agents do |t|
      t.string :name,              :null => false, :default => "Unknown"
      t.references :business
    end
  end
end

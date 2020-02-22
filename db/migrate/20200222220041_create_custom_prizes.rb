class CreateCustomPrizes < ActiveRecord::Migration
  def change
    create_table :custom_prizes do |t|

      t.references :admpart
      t.references :agent
      t.references :tag

      t.decimal    :amount

      t.timestamps
    end
  end
end

class CreateMonthTagTotals < ActiveRecord::Migration
  def change
    create_table :month_tag_totals do |t|

      t.references :tag
      t.date       :ref_date

      t.decimal    :total_amount

      t.timestamps
    end
  end
end

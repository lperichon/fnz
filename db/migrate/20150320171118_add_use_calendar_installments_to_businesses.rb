class AddUseCalendarInstallmentsToBusinesses < ActiveRecord::Migration
  def change
    add_column :businesses, :use_calendar_installments, :boolean, :default => true
  end
end

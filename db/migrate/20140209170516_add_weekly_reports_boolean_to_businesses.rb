class AddWeeklyReportsBooleanToBusinesses < ActiveRecord::Migration
  def change
    add_column :businesses, :send_weekly_reports, :boolean, :default => true
  end
end

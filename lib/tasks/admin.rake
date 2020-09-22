task :update_all_order_stamps => :environment do
  Transaction.update_all_order_stamps
end
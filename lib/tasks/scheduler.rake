desc "This task is called by the Heroku scheduler add-on it synchronizes contacts with Padma for all businesses"
task :synchronize  => :environment do
  Business.where("padma_id IS NOT NULL").each do |business|
    puts "Synchronizing Padma Contacts for #{business.name}..."
    PadmaContactsSynchronizer.new(business).sync
    puts "done."
  end
end

desc "This task is called by the Heroku scheduler add-on it creates monthly installments for all open memberships"
task :create_monthly_installments  => :environment do
  # Only run the first day of the month
  return unless Date.today.day == 1

  Business.where("padma_id IS NOT NULL").each do |business|
    puts "Creating installments for #{business.name}..."
    MonthlyInstallmentsCreator.new(business).run
    puts "done."
  end
end

desc "This task is called by the Heroku scheduler add-on it broadcasts end of membership 1 month before"
task :broadcast_end_of_memberships => :environment do
  Business.where("padma_id IS NOT NULL").each do |business|
    puts "Broadcasting end of memberships for #{business.name}..."
    MonthlyMembershipEndsBroadcaster.new(business).run
    puts "done."
  end
end
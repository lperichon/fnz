desc "This task is called by the Heroku scheduler add-on it synchronizes contacts with Padma for all businesses"
task :synchronize  => :environment do
  Business.where("padma_id IS NOT NULL").each do |business|
    puts "Synchronizing Padma Contacts for #{business.name}..."
    PadmaContactsSynchronizer.new(business).sync
    puts "done."
  end
end
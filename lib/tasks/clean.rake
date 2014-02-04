namespace :db do
  task :delete_all => :environment do
    if Rails.env.staging?
      [Business, Agent, User, Contact, Account, Import, Product, Sale, Membership, Enrollment, Installment, Transaction].each do |k|
        puts "calling delete_all on #{k}"
        k.delete_all
      end
    else
      puts "you are not on staging"
    end
  end
end

desc "This task stores the current membership directly on the contact"
task :store_membership  => :environment do
  Contact.includes(:memberships).all.each do |student|
  	membership = student.memberships.where(:business_id => student.business_id).where(:closed_on => nil).last
  	if membership
  		student.current_membership = membership
  		student.save
  	end
  end
end

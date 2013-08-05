class MonthlyMembershipEndsBroadcaster
  attr_accessor :business

  def initialize(business)
    @business = business
  end

  def run
    business.memberships.each do |membership|
      unless membership.closed? || membership.overdue?
        # Send notification using the messaging system
        Messaging::Client.post_message('membership_end', membership.as_json_for_messaging) if membership.ends_on == 30.days.from_now.to_date
      end
    end
  end
end
class MessageProcessor
  extend SsoSessionsHelper

  def self.catch_message(key_name, data)
    if key_name == "sso_session_destroyed"
      set_sso_session_destroyed_flag(data[:username])
    elsif key_name == "updated_contact" || key_name == "created_contact"
      Delayed::Job.enqueue FetchCrmContactJob.new(id: data[:id])
    elsif key_name == 'subscription_change'
      Delayed::Job.enqueue FetchCrmContactJob.new(id: data[:contact_id], business_padma_id: data[:account_name])
      #if data[:type] == 'Enrollment'
      # TODO: Create Membership using data from message
      #elsif data[:type] == 'DropOut'
      # TODO: Close Membership
      #end
    end
  end
end

class PadmaAccountsSynchronizer
  attr_accessor :business

  def initialize(business)
    @business = business
  end

  def sync
    # Synchronize the admin/owner
    padma_account = business.padma
    padma_admin = padma_account.admin
    if business.owner.blank? || padma_admin.username != business.owner.drc_uid
      new_fnz_owner = User.find_or_initialize_by_drc_uid(drc_uid: padma_admin.username, :email => padma_admin.username + "@metododerose.org")
      business.owner = new_fnz_owner
      business.save
    end

    business.users.each do |user|
      # Remove users not present on Padma
      business.users.delete(user) unless padma_account.users.collect(&:id).include?(user.drc_uid)
    end

    business.agents.each do |agent|
      # Enable/Disable agents
      if padma_account.users.collect(&:id).include?(agent.padma_id)
        agent.update_attribute(:disabled, false)
      else  
        agent.update_attribute(:disabled, true)
      end
    end

    # Add new users / agents
    padma_account.users.each do |padma_user|
      #initialize users
      new_user = User.find_or_create_by_drc_uid(drc_uid:padma_user.id, email: padma_user.email)
      business.users << new_user unless business.users.include?(new_user)
      #initialize agents
      business.agents.create(name: padma_user.id.gsub('.',' ').titleize, padma_id: padma_user.id) unless business.agents.collect(&:padma_id).include?(padma_user.id)
    end

    # Add owner as agent
    agents.create(name: business.owner.drc_uid.gsub('.',' ').titleize, padma_id: business.owner.drc_uid) unless business.agents.collect(&:padma_id).include?(business.owner.drc_uid)
  end
end
desc "resyncroniza alumnos y exalumnos de :account_name"
task resync_contacts: :environment do
  School.all.each do |b|
    if b.padma.try(:enabled?)
      b.queue_syncs_from_crm
    end
  end
end

task send_current_memberships: :environment do
  School.all.each do |b|
    if b.padma.try(:enabled?)
      b.contacts.where.not(current_membership_id: nil).includes(:current_membership).each do |c|
        c.current_membership.try :send_to_crm_if_current if c
      end
    end
  end
end

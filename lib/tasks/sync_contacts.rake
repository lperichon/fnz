desc "resyncroniza alumnos y exalumnos de :account_name"
task resync_contacts: :environment do
  School.all.each do |b|
    b.queue_syncs_from_crm
  end
end
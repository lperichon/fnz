desc "resyncroniza alumnos y exalumnos de :account_name"
task resync_contacts: :environment do
  School.all.each do |b|
    if b.padma.try(:enabled?)
      b.queue_syncs_from_crm
    end
  end
end
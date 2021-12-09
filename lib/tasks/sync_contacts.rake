desc "resyncroniza alumnos y exalumnos de :account_name"
task resync_contacts: :environment do
  per_page = ENV["per_page"] || 1000
  if (account_name = ENV["account_name"])
    CrmLegacyContact.paginate(
      account_name: account_name,
      per_page: per_page,
      where: {local_status: %W(student former_student)}
    ).each do |pc|
      FetchCrmContactJob.new(id: pc.id, business_padma_id: account_name).perform
    end
  end
end
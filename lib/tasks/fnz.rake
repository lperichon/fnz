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

task :tag_installment_transactions => :environment do
  all_installments_tags = Tag.where(system_name: "installment").all
  School.all.each do |b|
    tag = b.tags.get_installments_tag
    next if tag.nil?
    Installment.includes(:membership, transactions: :tags)
      .where(memberships: { business_id: b.id })
      .where(status: "complete")
      .where("due_on > ?", 7.months.ago)
      .each do |i|
        i.transactions.each do |tr|
          if tr.admpart_tag_id != tag.id
            tr.skip_update_balances= true
            tr.skip_infer_associations= true
            tr.update_attributes(
              tag_id: tag.id,
              admpart_tag_id: tag.id,
              contact_id: i.try(:membership).try(:contact_id),
              agent_id: i.agent_id
            )
          end
        end
    end
  end
end

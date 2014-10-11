module MembershipsHelper

  def suggested_agent_id_for(business,membership)
    agents = business.agents.where(name: membership.contact.padma_teacher)
    agents.empty?? nil : agents.first.id
  end

  def sidebar_contact_membership_link(contact, membership)
    str = contact.name.html_safe
    str << overdue_fire_warning(membership)
    content_tag(:li,
                link_to(str, membership.present? ? business_membership_path(@business, membership) : new_business_membership_path(@business, :membership => {:contact_id => contact.id})),
                'data-contact-id' => contact.id, 'data-html' => true, 'data-content' => "#{render(:partial => 'memberships/contact_popover', :locals => {:membership => membership})}", :rel => "popover", 'data-placement' => "right", 'data-original-title' => contact.name, 'data-triggr' => "hover",
                :class => [link_is_active?(contact)? 'active' : '',  contact.padma_status].join(" ")
    )
  end

  def table_contact_membership_link(contact, membership)
  	link_to(membership.present? ? t('memberships.overview.close_membership') : t('memberships.secondary_navigation.new_membership') , membership.present? ? edit_business_membership_path(@business, membership) : new_business_membership_path(@business, :membership => {:contact_id => contact.id}))
  end

  # Renders contacts membership end_date if available. Empty string if not.
  # @return [String]
  def membership_end_date(contact)
    content_tag(:span, contact.try(:membership).try(:ends_on), :class => "pull-right")
  end

  # Renders a fire warning icon if membership is missing, due or overdue (color varies)
  # @return [String]
  def overdue_fire_warning(membership)
    if membership.blank? || membership.due? || membership.overdue?
      content_tag(:i, "", :class => "#{membership.present? ? (membership.due? ? 'due' : 'overdue') : 'missing'}-membership pull-right icon-fire")
    end
  end

  # Renders membership's paymet type
  # @return [String]
  def memberships_payment_type_name(membership)
    content_tag(:span, membership.try(:payment_type).try(:name)).html_safe
  end

  # @return [Boolean]
  def link_is_active?(contact)
    (@membership.present? && @membership.persisted? && contact.id == @membership.contact.id)
  end

  # @return [Installment]
  def installment_for(date, installments)
  	installments.detect {|i| i.due_on.beginning_of_month.beginning_of_day <= date && i.due_on.end_of_month.end_of_day >= date}
  end
end

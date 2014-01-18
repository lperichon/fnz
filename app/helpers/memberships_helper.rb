module MembershipsHelper

  def sidebar_contact_membership_link(contact)
    str = contact.name.html_safe
    str << memberships_payment_type_name(contact)
    str << overdue_fire_warning(contact)
    str << membership_end_date(contact)
    content_tag(:li,
                link_to(str, contact.membership.present? ? business_membership_path(@business, contact.membership) : new_business_membership_path(@business, :membership => {:contact_id => contact.id})),
                :class => [link_is_active?(contact)? 'active' : '',  contact.padma_status].join(" ")
    )
  end

  def table_contact_membership_link(contact)
  	link_to(contact.membership.present? ? "Close membership" : "New membership" , contact.membership.present? ? business_membership_path(@business, contact.membership) : new_business_membership_path(@business, :membership => {:contact_id => contact.id}))
  end	

  # Renders contacts membership end_date if available. Empty string if not.
  # @return [String]
  def membership_end_date(contact)
    content_tag(:span, contact.try(:membership).try(:ends_on), :class => "pull-right")
  end

  # Renders a fire warning icon if membership is missing, due or overdue (color varies)
  # @return [String]
  def overdue_fire_warning(contact)
    if contact.membership.blank? || contact.membership.due? || contact.membership.overdue?
      content_tag(:i, "", :class => "#{contact.membership.present? ? (contact.membership.due? ? 'due' : 'overdue') : 'missing'}-membership pull-right icon-fire")
    end
  end

  # Renders membership's paymet type
  # @return [String]
  def memberships_payment_type_name(contact)
    (" (" + content_tag(:span, contact.try(:membership).try(:payment_type).try(:name)) + ") ").html_safe
  end

  # @return [Boolean]
  def link_is_active?(contact)
    (@membership.present? && @membership.persisted? && contact.id == @membership.contact.id)
  end
end
module MembershipsHelper

  def duration_in_words(membership)
    distance_of_time_in_words(membership.ends_on,membership.begins_on)
  end

  def attributes_for_duplicate(membership)

    new_ends_on = membership.ends_on+(membership.ends_on-membership.begins_on)+1.day
    if membership.ends_on == membership.ends_on.end_of_month
      new_ends_on = nearest_end_of_month(membership.ends_on)
    end

    {
      contact_id: membership.contact_id,
      name: membership.name,
      value: membership.value,
      payment_type_id: membership.payment_type_id,
      monthly_due_day: membership.monthly_due_day,
      begins_on: membership.ends_on+1.day,
      ends_on: new_ends_on
    }
  end

  def nearest_end_of_month(date)
    tolerance = 5.days # days
    eo = date.end_of_month
    if date + tolerance < eo
      # if casting moves date more than tolerance days ahead
      # return previous end of month
      (date - 1.month).end_of_month
    else
      eo
    end
  end

  def suggested_agent_id_for(business,membership)
    agents = business.agents.enabled.where(padma_id: membership.contact.padma_teacher)
    agents.empty?? nil : agents.first.id
  end

  def sidebar_contact_membership_link(business, contact, membership)
    str = contact.name.html_safe
    str << overdue_fire_warning(membership, contact)
    content_tag(:span,
      link_to(str, business_contact_path(business, contact)),
      'data-contact-id' => contact.id, 'data-html' => true, 'data-content' => "#{render(:partial => 'memberships/contact_popover', :locals => {:membership => membership, :contact => contact})}", :rel => "popover", 'data-placement' => "right", 'data-original-title' => contact.name, 'data-triggr' => "hover",
      :class => [link_is_active?(contact) ? 'active' : '', contact.padma_status].join(" ")
    )
  end

  def table_contact_membership_link(contact, membership)
    if membership.present?
      link_to(t('memberships.overview.close_membership'),
              business_membership_path(@business,
                                       membership,
                                       membership: {closed_on: Date.today},
                                       return_to: request.url
                                      ),
              method: :put,
              class: "btn btn-warning")
    else  
      link_to(t('memberships.secondary_navigation.new_membership') , new_business_membership_path(@business, :membership => {:contact_id => contact.id}), :class => "btn btn-primary")
    end
  end

  # Renders contacts membership end_date if available. Empty string if not.
  # @return [String]
  def membership_end_date(contact)
    content_tag(:span, contact.try(:membership).try(:ends_on), :class => "pull-right")
  end

  # Renders a fire warning icon if membership is missing, due or overdue (color varies)
  # @return [String]
  def overdue_fire_warning(membership, contact)
    if membership.blank? || membership.due? || membership.overdue? || contact.padma_status == "former-student"
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
    (@membership.present? && @membership.persisted? && contact.id == @membership.contact_id)
  end

  # @return [Installment]
  def installment_for(date, installments)
    date = date.to_date
    installments.detect {|i| date.beginning_of_month <= i.due_on && i.due_on <= date.end_of_month } # detect = select{}.first
  end
end

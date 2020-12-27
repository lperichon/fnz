class PaymentStatusInput < SimpleForm::Inputs::Base
  def input
    out = '' # the output string we're going to build
    value = object.status
    business = options[:business]
    out << template.content_tag(:span, value, :class => "label label-#{value}")
    if !object.new_record? && !business.transactions_enabled? && object.complete?
    	 out << template.link_to(template.content_tag(:i, "", :class => "icon-trash"), template.business_transaction_path(business, object.trans.first), data: {:confirm => template.t('actions.confirm_delete')}, :method => 'delete')
    end
    out.html_safe
  end
end

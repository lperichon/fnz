class PaymentStatusInput < SimpleForm::Inputs::Base
  def input
    out = '' # the output string we're going to build
    value = object.status
    (out << template.content_tag(:span, value, :class => "label label-#{value}")).html_safe
  end
end

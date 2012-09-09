class DateTimePickerInput < SimpleForm::Inputs::Base
  def input
    out = '' # the output string we're going to build
    out << template.text_field_tag("datepicker_" + attribute_name.to_s, object.send(attribute_name), :class => "datepicker_input inline")
    out << template.text_field_tag("timepicker_" + attribute_name.to_s, object.send(attribute_name), :class => "timepicker_input inline")
    (out << @builder.hidden_field(attribute_name, input_html_options)).html_safe
  end
end

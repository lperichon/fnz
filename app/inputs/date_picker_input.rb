class DatePickerInput < SimpleForm::Inputs::Base
  def input
    out = '' # the output string we're going to build
    value = object.send(attribute_name)
    out << template.text_field_tag("datepicker_" + attribute_name.to_s, value ? value.to_s(:datepicker) : "", :class => "datepicker_input inline")
    (out << @builder.hidden_field(attribute_name, input_html_options)).html_safe
  end
end

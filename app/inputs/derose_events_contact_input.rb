class DeroseEventsContactInput < SimpleForm::Inputs::Base
  def input
    out = '' # the output string we're going to build
    value = object.send(:contact).try(:name)
    (out << @builder.hidden_field(attribute_name, input_html_options.reverse_merge({data: {name: value}}))).html_safe
  end
end

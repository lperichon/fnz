$(document).ready ->
  $("form").nestedFields();

  $("#sale_contact_id").chosen
    allow_single_deselect: true
    no_results_text: "No results matched"
    create_option: (name) ->
      chosen = this
      $.post "/businesses/" + $("#sale_contact_id").attr('data-business-id') + "/contacts.json",
        contact:
          name: name
      , (data) ->
        chosen.append_option
          value: data.id
          text: data.name

    persistent_create_option: true

  $("#sale_product_id").chosen
    allow_single_deselect: true
    no_results_text: "No results matched"
    create_option: (name) ->
      chosen = this
      $.post "/businesses/" + $("#sale_product_id").attr('data-business-id') + "/products.json",
        product:
          name: name
      , (data) ->
        chosen.append_option
          value: data.id
          text: data.name

    persistent_create_option: true
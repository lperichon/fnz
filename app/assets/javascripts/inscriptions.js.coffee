$(document).ready ->
  
  $("#inscription_payment_type_id").chosen
    no_results_text: "No results matched"
    create_option: (name) ->
      chosen = this
      $.post "/businesses/" + $("#inscription_payment_type_id").attr('data-business-id') + "/payment_types.json",
        payment_type:
          name: name
      , (data) ->
        chosen.append_option
          value: data.id
          text: data.name

    persistent_create_option: true

  $("#inscription_contact_id").chosen
    no_results_text: "No results matched"
    create_option: (name) ->
      chosen = this
      $.post "/businesses/" + $("#inscription_contact_id").attr('data-business-id') + "/contacts.json",
        contact:
          name: name
      , (data) ->
        chosen.append_option
          value: data.id
          text: data.name

    persistent_create_option: true

  $("#inscription_search_payment_type_id").chosen
    allow_single_deselect: true

  $("#inscription_search_payment_type_id").change ->
    $(this).addClass('btn-primary')
    $('#update-filter').addClass('btn-success')
    $('#update-filter').show()


  $("#update-filter").click ->
    $("#new_inscription_search").submit()

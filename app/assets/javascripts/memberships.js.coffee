$(document).ready ->
  $("#membership_payment_type_id").chosen
    no_results_text: "No results matched"
    create_option: (name) ->
      chosen = this
      $.post "/businesses/" + $("#membership_payment_type_id").attr('data-business-id') + "/payment_types.json",
        payment_type:
          name: name
      , (data) ->
        chosen.append_option
          value: data.id
          text: data.name

    persistent_create_option: true

  $("#membership_contact_id.chosen").chosen
    no_results_text: "No results matched"
    create_option: (name) ->
      chosen = this
      $.post "/businesses/" + $("#membership_contact_id").attr('data-business-id') + "/contacts.json",
        contact:
          name: name
      , (data) ->
        chosen.append_option
          value: data.id
          text: data.name

    persistent_create_option: true

  $(".students.nav li").popover()

  $(".table.memberships tr").hover (->
    contact_id = $(this).attr("data-contact-id")
    $(".students.nav li[data-contact-id='" + contact_id + "'] a").addClass "contact-hover"
  ), (->
    contact_id = $(this).attr("data-contact-id")
    $(".students.nav li[data-contact-id='" + contact_id + "'] a").removeClass "contact-hover"
  )

  $(".students.nav li").hover (->
    contact_id = $(this).attr("data-contact-id")
    $(".table.memberships tr[data-contact-id='" + contact_id + "']").addClass "contact-hover"
  ), (->
    contact_id = $(this).attr("data-contact-id")
    $(".table.memberships tr[data-contact-id='" + contact_id + "']").removeClass "contact-hover"
  )

  # maturity_report form
  $("#period-options a").click ->
    $("#period-options a").removeClass('btn-primary')
    $(this).addClass('btn-primary')
    $('#update-filter').addClass('btn-success')
    $('#update-filter').show()

  $(".easy-period").click ->
    $("#custom-period-select").hide()
    $("#membership_search_ends_after").val($(this).data('ends-after'))
    $("#membership_search_ends_before").val($(this).data('ends-before'))

  $('#custom-period').click ->
    $("#custom-period-select").show()

  $("#update-filter").click ->
    $("#new_membership_search").submit()

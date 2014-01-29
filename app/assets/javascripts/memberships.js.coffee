$(document).ready ->
  $("#membership_contact_id, #membership_payment_type_id").chosen
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
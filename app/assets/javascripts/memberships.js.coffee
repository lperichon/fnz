$(document).ready ->

  $('td[data-toggle="tooltip"]').tooltip()

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
  $(".installment-value").popover({html: true})

  $('#list-transactions-modal').on 'show', (event) =>
      console.log(event)
      name = $(this).data('modal').options.person
      $(this).find('.person').html(name)

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

  $("table#memberships tr:not(:first-child)").click ->
    window.location.href = $(this).data('membership_url')

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

  $("#membership_search_payment_type_id").chosen
    allow_single_deselect: true

  $("#contact_search_membership_payment_type_id").chosen
    allow_single_deselect: true

  $("#contact_search_teacher").chosen
    allow_single_deselect: true

  $("#contact_search_status").chosen
    allow_single_deselect: true

  $("#contact_search_membership_status").chosen
    allow_single_deselect: true

  $("#membership_search_payment_type_id").change ->
    $(this).addClass('btn-primary')
    $('#update-filter').addClass('btn-success')
    $('#update-filter').show()

  $("a.mark_as_paid_link").click ->
    $(this).html('<div class="loader">Loading...</div>')

  $("#multiple_mark_as_paid").click (e) ->
    e.preventDefault()
    valuesToSubmit = $('form#multiple_installments').serialize()

    totalAmount = 0
    totalAmount += parseInt($(selectedCheckbox).parents('tr').data('amount'),10) for selectedCheckbox in $("#multiple_installments input[type=checkbox]:checked")

    valuesToSubmit += "&transaction[amount]=#{totalAmount}"

    $.ajax(
      type: 'GET'
      url: $(this).attr('href')
      data: valuesToSubmit
      dataType: 'script')

  checkboxes = $("form#multiple_installments input[type='checkbox']")
  submitButt = $("#multiple_mark_as_paid")

  checkboxes.click ->
    submitButt.attr("disabled", !checkboxes.is(":checked"))

  $(document.body).on "click", ".link-transaction-to-installment-form", (e) ->
    tr = $(this).parents('tr')
    id = tr.attr('data-id')
    random = $.now()
    tr.hide()
    input = '<input id="' + 'transactions_ids_' + random + '" name="installment[transaction_ids][]" value="' + id + '" type="hidden">'
    $(".installment_transaction_select_form").append(input)
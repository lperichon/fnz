$(document).ready ->
  $("#installment-search-period-options a").click ->
    $("#installment-search-period-options a").removeClass('btn-primary')
    $(this).addClass('btn-primary')
    $('#update-installment-filter').addClass('btn-success')
    $('#update-installment-filter').show()

  $(".installment-search-easy-period").click ->
    $("#installment-search-custom-period-select").hide()
    $("#installment_search_due_after").val($(this).data('due-after'))
    $("#installment_search_due_before").val($(this).data('due-before'))

  $('#installment-search-custom-period').click ->
    $("#installment-search-custom-period-select").show()

  $("#update-installment-filter").click ->
    $("#new_installment_search").submit()

  $("#installment_search_payment_type_id").chosen
    allow_single_deselect: true

  $("#installment_search_status").chosen
    allow_single_deselect: true

  $("#installment_search_status").change ->
    $(this).addClass('btn-primary')
    $('#update-installment-filter').addClass('btn-success')
    $('#update-installment-filter').show()

  $("#installment_search_agent_id").chosen
    allow_single_deselect: true

  $("#installment_search_agent_id").change ->
    $(this).addClass('btn-primary')
    $('#update-installment-filter').addClass('btn-success')
    $('#update-installment-filter').show()

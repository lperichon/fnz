$(document).ready ->
  $("select.chosen").chosen({no_results_text: "No results matched"});

  $('#new-transaction-modal').on 'hidden', () ->
    $('#new-transaction-modal form')[0].reset()


  $("#new_transaction").on "ajax:success", (event, data, status, xhr) ->
    $('#new-transaction-modal').modal('hide')
    $('table tbody').append('<tr><td>' + "test" + '</td><td>' + "test" + '</td></tr>')

  $(".remove-nested-transaction").on "click", (e) ->
    $(this).siblings(".destroy-value").val(true)
    $(this).parents("tr").hide()

  $("#add_nested").on "click", (e) ->
    console.log('#new-transaction-modal #transaction_' + $(this).attr('data-parent-type') + '_ids')
    $('#new-transaction-modal #transaction_' + $(this).attr('data-parent-type') + '_ids').val($(this).attr('data-parent-id'))

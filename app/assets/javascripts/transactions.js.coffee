$(document).ready ->
  $("#transaction_tag_ids").chosen({no_results_text: "No results matched"});

  $("#new_transaction").on "ajax:success", (event, data, status, xhr) ->
    $('#new-transaction-modal').modal('hide')
    $('table tbody').append('<tr><td>' + "test" + '</td><td>' + "test" + '</td></tr>')

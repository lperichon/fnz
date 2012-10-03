$(document).ready ->
  $("select.chosen").chosen({no_results_text: "No results matched"});

  $('[data-dismiss="modal"]').on 'click', () ->
    $('#new-transaction-modal form')[0].reset()

  $(".remove-nested-transaction").on "click", (e) ->
    $(this).siblings(".destroy-value").val(true)
    $(this).parents("tr").hide()

  $(".remove-unsaved-nested-transaction").live "click", (e) ->
    $(this).parents("tr").remove()

  $("#add_nested").on "click", (e) ->
    $('#new-transaction-modal #transaction_' + $(this).attr('data-parent-type') + '_ids').val($(this).attr('data-parent-id'))

  $(".link-transaction-button").on "click", (e) ->
    tr = $(this).parents('tr')
    random = $.now()
    parent_type = $(".nested.transactions.table").attr('data-type')
    id = tr.attr('data-id')
    tr.children('td:last').html('<a href="#" class="remove-unsaved-nested-transaction"><i class="icon-remove"></i></a><input id="' + parent_type + '_transactions_attributes_' + random + '_transaction_id" name="' + parent_type + '[' + parent_type + '_transactions_attributes][' + random + '][transaction_id]" value="' + id + '" type="hidden">')
    $(".nested.transactions.table").append(tr)

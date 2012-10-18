$(document).ready ->
  $('[data-dismiss="modal"]').live 'click', () ->
    $(this).parents('.modal').remove();

  $("#transaction_type_transfer").live "change", ->
    $(".transfer_field").children().removeAttr("disabled");
    $(".transfer_field").show();
  $("#transaction_type_debit, #transaction_type_credit").live "change", ->
    $(".transfer_field").children().attr("disabled",true);
    $(".transfer_field").hide();

  $("#transaction_state").live "change", ->
    if $("#transaction_state").val() == "reconciled"
      $(".pending_field").children().removeAttr("disabled");
      $(".pending_field").show();
    else
      $(".pending_field").children().attr("disabled",true);
      $(".pending_field").hide();

  $(".remove-nested-transaction").on "click", (e) ->
    $(this).siblings(".destroy-value").val(true)
    $(this).parents("tr").hide()

  $(".remove-unsaved-nested-transaction").live "click", (e) ->
    $(this).parents("tr").remove()

  $(".link-transaction-button").on "click", (e) ->
    tr = $(this).parents('tr')
    random = $.now()
    parent_type = $(".nested.transactions.table").attr('data-type')
    id = tr.attr('data-id')
    tr.children('td:last').html('<a href="#" class="remove-unsaved-nested-transaction"><i class="icon-remove"></i></a><input id="' + parent_type + '_transactions_attributes_' + random + '_transaction_id" name="' + parent_type + '[' + parent_type + '_transactions_attributes][' + random + '][transaction_id]" value="' + id + '" type="hidden">')
    $(".nested.transactions.table").append(tr)

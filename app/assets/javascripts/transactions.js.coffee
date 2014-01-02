$(document).ready ->
  $(document.body).on 'click', '[data-dismiss="modal"]', () ->
    $(this).parents('.modal').remove();

  $(document.body).on "change", "#transaction_type_transfer", ->
    $(".transfer_field").children().removeAttr("disabled");
    $(".transfer_field").show();
  $(document.body).on "change", "#transaction_type_debit, #transaction_type_credit", ->
    $(".transfer_field").children().attr("disabled",true);
    $(".transfer_field").hide();

  $(document.body).on "change", "#transaction_state", ->
    if $("#transaction_state").val() == "reconciled"
      $(".pending_field").children().removeAttr("disabled");
      $(".pending_field").show();
    else
      $(".pending_field").children().attr("disabled",true);
      $(".pending_field").hide();

  $(document.body).on "click", ".remove-nested-transaction", (e) ->
    $(this).siblings(".destroy-value").val(true)
    $(this).parents("tr").hide()

  $(document.body).on "click", ".remove-unsaved-nested-transaction", (e) ->
    $(this).parents("tr").remove()

  $(document.body).on "click", ".link-transaction-button", (e) ->
    tr = $(this).parents('tr')
    random = $.now()
    parent_type = $(".nested.transactions.table").attr('data-type')
    id = tr.attr('data-id')
    tr.children('td:last').html('<a href="#" class="remove-unsaved-nested-transaction"><i class="icon-remove"></i></a><input id="' + parent_type + '_transactions_attributes_' + random + '_transaction_id" name="' + parent_type + '[' + parent_type + '_transactions_attributes][' + random + '][transaction_id]" value="' + id + '" type="hidden">')
    $(".nested.transactions.table").append(tr)

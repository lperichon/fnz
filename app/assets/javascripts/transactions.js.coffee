$(document).ready ->
  $(document.body).on 'click', '#new-transaction-modal [data-dismiss="modal"], #transaction-stats-modal [data-dismiss="modal"], #sale-stats-modal [data-dismiss="modal"],  #membership-stats-modal [data-dismiss="modal"], #new-payment-modal [data-dismiss="modal"]', () ->
    $(this).parents('.modal').remove();

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

  $("#transaction_search_daterange").daterangepicker
    opens: "left",
    ranges:
      "Today": [
        moment()
        moment()
      ]
      "This Week": [
        moment().startOf("week")
        moment()
      ]
      "This Month": [
        moment().startOf("month")
        moment().endOf("month")
      ]
      "Last Month": [
        moment().subtract(1, "month").startOf("month")
        moment().subtract(1, "month").endOf("month")
      ],
      "Month before last": [
        moment().subtract(2, "month").startOf("month")
        moment().subtract(2, "month").endOf("month")
      ]
    , (start, end) ->
      window.location = "?start_date=" + start.format("YYYY-M-D") + "&end_date=" + end.format("YYYY-M-D")


  jQuery(".best_in_place").best_in_place();

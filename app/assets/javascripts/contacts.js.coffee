$(document).ready ->
  $("#transaction_type_transfer").change ->
    $(".transfer_field").children().removeAttr("disabled");
    $(".transfer_field").show();
  $("#transaction_type_debit, #transaction_type_credit").change ->
    $(".transfer_field").children().attr("disabled",true);
    $(".transfer_field").hide();

  $("#transaction_state").change ->
    if $("#transaction_state").val() == "reconciled"
      $(".pending_field").children().removeAttr("disabled");
      $(".pending_field").show();
    else
      $(".pending_field").children().attr("disabled",true);
      $(".pending_field").hide();
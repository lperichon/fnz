$(document).ready ->

  $("#import_type").change ->
    val = $('#import_type :selected').val()
    if val == "TransactionImport"
      $(".field").hide()
      $(".transaction.field").show()
    else if val == "SantanderRioArImport"
      $(".field").hide()
      $(".santander.field").show()
  
  val = $('#import_type :selected').val()
  if val == "TransactionImport"
    $(".field").hide()
    $(".transaction.field").show()
  else if val == "SantanderRioArImport"
    $(".field").hide()
    $(".santander.field").show()
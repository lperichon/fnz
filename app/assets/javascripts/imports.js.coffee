$(document).ready ->

  $("#archiveAndRedirectBtn").on("ajax:complete", ->
    location.href=$("#archiveAndRedirectBtn").data("redirectToUrl")
  )

  $("#import_type").change ->
    val = $('#import_type :selected').val()
    if val == "TransactionImport"
      $(".field").hide()
      $(".transaction.field").show()
    else if val == "SantanderRioArImport" || val =="MercadopagoImport" || val == "GaliciaOfficeArImport"
      $(".field").hide()
      $(".santander.field").show()
  
  val = $('#import_type :selected').val()
  if val == "TransactionImport"
    $(".field").hide()
    $(".transaction.field").show()
  else if val == "SantanderRioArImport" || val =="MercadopagoImport" || val == "GaliciaOfficeArImport"
    $(".field").hide()
    $(".santander.field").show()



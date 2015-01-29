$(document).ready ->
  $("form").nestedFields();

  $("#sale_search_daterange").daterangepicker
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
        moment().subtract("month", 1).startOf("month")
        moment().subtract("month", 1).endOf("month")
      ]
    , (start, end) ->
      window.location = "?start_date=" + start.format("YYYY-M-D") + "&end_date=" + end.format("YYYY-M-D")


  $("#sale_product_id").chosen
    allow_single_deselect: true
    no_results_text: "No results matched"
    create_option: (name) ->
      chosen = this
      $.post "/businesses/" + $("#sale_product_id").attr('data-business-id') + "/products.json",
        product:
          name: name
      , (data) ->
        chosen.append_option
          value: data.id
          text: data.name

    persistent_create_option: true


  $("#sale_contact_id.chosen").chosen
    allow_single_deselect: true
    no_results_text: "No results matched"
    create_option: (name) ->
      chosen = this
      $.post "/businesses/" + $("#sale_contact_id").attr('data-business-id') + "/contacts.json",
        contact:
          name: name
      , (data) ->
        chosen.append_option
          value: data.id
          text: data.name

    persistent_create_option: true
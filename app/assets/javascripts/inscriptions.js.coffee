$(document).ready ->
  
  $("#inscription_payment_type_id").chosen
    no_results_text: "No results matched"
    create_option: (name) ->
      chosen = this
      $.post "/businesses/" + $("#inscription_payment_type_id").attr('data-business-id') + "/payment_types.json",
        payment_type:
          name: name
      , (data) ->
        chosen.append_option
          value: data.id
          text: data.name

    persistent_create_option: true

  $("#inscription_contact_id").chosen
    no_results_text: "No results matched"
    create_option: (name) ->
      chosen = this
      $.post "/businesses/" + $("#inscription_contact_id").attr('data-business-id') + "/contacts.json",
        contact:
          name: name
      , (data) ->
        chosen.append_option
          value: data.id
          text: data.name

    persistent_create_option: true

  $("#inscription_search_payment_type_id").chosen
    allow_single_deselect: true

  $("#inscription_search_payment_type_id").change ->
    $(this).addClass('btn-primary')
    $('#update-filter').addClass('btn-success')
    $('#update-filter').show()


  $("#inscription_search_agent_padma_id").chosen
    allow_single_deselect: true

  $("#inscription_search_agent_padma_id").change ->
    $(this).addClass('btn-primary')
    $('#update-filter').addClass('btn-success')
    $('#update-filter').show()


  $("#update-filter").click ->
    $("#new_inscription_search").submit()

  if $("#inscriptions_chart").length > 0
    inscriptionsChart = new (Highcharts.Chart)(
      chart:
        height: 250
        width: 350
        renderTo: 'inscriptions_chart'
        plotBackgroundColor: null
        plotBorderWidth: null
        plotShadow: false
      title: text: ''
      tooltip:
        pointFormat: '<b>{point.y}</b>'
        valueDecimals: 2
        valuePrefix: '$'
      plotOptions: pie:
        allowPointSelect: true
        cursor: 'pointer'
        dataLabels:
          enabled: true
          color: '#000000'
          connectorColor: '#000000'
          formatter: ->
            '<b>' + @point.name + '</b>: $' + @y
        showInLegend: false
      series: [ {
        type: 'pie'
        name: 'Inscriptions'
        data: $('#inscriptions_chart').data('data')
        enableMouseTracking: false
        shadow: false
        animation: false
      } ])

  if $("#credits_chart").length > 0
    creditsChart = new (Highcharts.Chart)(
      chart:
        height: 250
        width: 350
        renderTo: 'credits_chart'
        plotBackgroundColor: null
        plotBorderWidth: null
        plotShadow: false
      title: text: ''
      tooltip:
        pointFormat: '<b>{point.y}</b>'
        valueDecimals: 2
        valuePrefix: '$'
      plotOptions: pie:
        allowPointSelect: true
        cursor: 'pointer'
        dataLabels:
          enabled: true
          color: '#000000'
          connectorColor: '#000000'
          formatter: ->
            '<b>' + @point.name + '</b>: $' + @y
        showInLegend: false
      series: [ {
        type: 'pie'
        name: 'Credits'
        data: $('#credits_chart').data('data')
        enableMouseTracking: false
        shadow: false
        animation: false
      } ])

  if $("#debits_chart").length > 0
    debitsChart = new (Highcharts.Chart)(
      chart:
        height: 250
        width: 350
        renderTo: 'debits_chart'
        plotBackgroundColor: null
        plotBorderWidth: null
        plotShadow: false
      title: text: ''
      tooltip:
        pointFormat: '<b>{point.y}</b>'
        valueDecimals: 2
        valuePrefix: '$'
      plotOptions: pie:
        allowPointSelect: true
        cursor: 'pointer'
        dataLabels:
          enabled: true
          color: '#000000'
          connectorColor: '#000000'
          formatter: ->
            '<b>' + @point.name + '</b>: $' + @y
        showInLegend: false
      series: [ {
        type: 'pie'
        name: 'Debits'
        data: $('#debits_chart').data('data')
        enableMouseTracking: false
        shadow: false
        animation: false
      } ])
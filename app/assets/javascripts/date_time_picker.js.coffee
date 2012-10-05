$(document).ready ->
  $('.datepicker_input').live "focus", (event) ->
    $(this).datepicker({"format": "yyyy-mm-dd", "weekStart": 1, "autoclose": true});
  $('.timepicker_input').live "focus", (event) ->
    $(this).timepicker();

  $('.datepicker_input, .timepicker_input').live "change", (event) ->
    value = $(this).parent().children(".datepicker_input").val() + " " +  $(this).parent().children(".timepicker_input").val()
    $(this).siblings(":hidden").val(value)
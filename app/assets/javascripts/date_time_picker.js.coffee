$(document).ready ->
  $('.datepicker_input').on "focus", (event) ->
    $(this).datepicker({"format": "yyyy-mm-dd", "weekStart": 1, "autoclose": true});
  $('.timepicker_input').on "focus", (event) ->
    $(this).timepicker();

  $('.datepicker_input, .timepicker_input').on "change", (event) ->
    value = $(this).parent().children(".datepicker_input").val() + " " +  $(this).parent().children(".timepicker_input").val()
    $(this).siblings(":hidden").val(value)
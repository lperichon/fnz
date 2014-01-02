$(document).ready ->
  $(document.body).on "focus", '.datepicker_input', (event) ->
    $(this).datepicker({"format": "yyyy-mm-dd", "weekStart": 1, "autoclose": true});
  $(document.body).on "focus", '.timepicker_input', (event) ->
    $(this).timepicker();

  $(document.body).on "change", '.datepicker_input, .timepicker_input', (event) ->
    value = $(this).parent().children(".datepicker_input").val() + " " +  $(this).parent().children(".timepicker_input").val()
    $(this).siblings(":hidden").val(value)
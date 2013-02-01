$(document).ready ->
  $(".required.chosen").chosen();
  $(".optional.chosen").chosen(allow_single_deselect: true);
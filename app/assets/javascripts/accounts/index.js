$(document).ready(function(){
  $('.refreshOnResponse').bind('ajax:complete', function() {
    location.reload();
  });
});

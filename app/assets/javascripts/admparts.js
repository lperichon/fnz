$(document).ready(function(){

  $(".draggable-tag").draggable({ revert: "invalid" });

  $(".droppable-section").droppable({
    greedy: true,
    classes: {
      "ui-droppable-active": "droppable-active",
      "ui-droppable-hover": "droppable-hover"
    },
    drop: function( event, ui ) {
      console.log("dropped here");
      console.log("calling: "+"/businesses/"+event.target.dataset.businessId+"/tags/"+event.toElement.dataset.tagId+" with "+event.target.dataset.sectionName);
      $.post("/businesses/"+event.target.dataset.businessId+"/tags/"+event.toElement.dataset.tagId,{
          _method: "put",
          tag: {
            admpart_section: event.target.dataset.sectionName
          }
      }, function(data, status){
        console.log(data);
        console.log(status);
      }, "json" );
    }
  });

  $("[data-action=redirectOnChange]").change(function(){
    var year = event.currentTarget.value.substring(0,4);
    var month = event.currentTarget.value.substring(5,7);
    window.location.href = "/businesses/"+event.currentTarget.dataset.businessId+"/admparts/"+year+"/"+month;
  });

})

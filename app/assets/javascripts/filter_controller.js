(()=>{
  stimulusApplication.register("filter", class extends Stimulus.Controller {
    static get targets(){
      // item : rows we'll search through
      // query : input for seach. Allow for "column:value" format.
      // header : used for querying specific columns
      return ["query","item","header"];
    }

    connect(){
    }

    filterItems(event){
      if(this.queryTarget.value == ""){
        this.itemTargets.forEach( el => { el.classList.remove("filter--noMatch") });
      } else if(this.queryIsSmart()){
        this.smartFilter();
      } else {
        this.generalFilter();
      }
      this.dispatchFilterevent();
    }

    generalFilter(){
      this.itemTargets.forEach((el,i) => {
        el.classList.toggle("filter--noMatch", !el.textContent.toLowerCase().match(this.queryTarget.value.toLowerCase()));
      });
    }

    smartFilter(){
      if(this.smartColumnIndex()){
        this.itemTargets.forEach((el,i) => {
          var content = el.querySelectorAll("td,th")[this.smartColumnIndex()].textContent;
          el.classList.toggle("filter--noMatch", !content.toLowerCase().match(this.smartValue().toLowerCase()));
        });
      }
    }

    dispatchFilterevent(){
      var e = new Event("listrefreshed");
      window.dispatchEvent(e);
    }

    queryIsSmart(){
      return this.queryTarget.value.match(":");
    }

    smartColumnIndex(){
      var tds = this.headerTarget.querySelectorAll("td,th");
      var i = 0;
      var columnIndex = null;
      for(i = 0; i < tds.length; i++){
        if(tds[i].textContent.toLowerCase().match(this.smartColumnName().toLowerCase())){
          columnIndex = i;
        }
      }
      return columnIndex;
    }

    smartColumnName(){
      return this.queryTarget.value.substring(0,this.queryTarget.value.match(":").index);
    }

    smartValue(){
      return this.queryTarget.value.substring(this.queryTarget.value.match(":").index+1);
    }
  });

})();

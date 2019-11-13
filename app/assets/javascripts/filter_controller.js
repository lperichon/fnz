(()=>{
  stimulusApplication.register("filter", class extends Stimulus.Controller {
    static get targets(){
      return ["query","item"];
    }

    connect(){
    }

    filterItems(event){
      if(this.queryTarget.value == ""){
        this.itemTargets.forEach( el => { el.classList.remove("filter--noMatch") });
      } else {
        this.itemTargets.forEach((el,i) => {
          el.classList.toggle("filter--noMatch", !el.textContent.toLowerCase().match(this.queryTarget.value.toLowerCase()));
        });
      }
    }
  });

})();

/*
  Al conectar pone
  * display:inherit en todos los hideElements
  * disabled:false en todos los disableElements
 */
(()=>{
  stimulusApplication.register("wait-for-js", class extends Stimulus.Controller {
    static get targets(){
      return ["hideElement", "disableElement"];
    }

    connect(){
      this.log("connect");
      if(this.hasHideElementTarget){
        this.hideElementTargets.forEach((e) => {
          this.log("show element " + e.id);
          e.style.display = "inherit";
        });
      }
      if(this.hasDisableElementTarget){
        this.disableElementTargets.forEach((e) => {
          e.disabled = false;
        });
      }
    }

    log(msg){
      console.log("[wait-for-js] " + msg);
    }

  });

})();

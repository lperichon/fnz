(()=>{
  stimulusApplication.register("balance_modal", class extends Stimulus.Controller {
    static get targets(){
      return ["expected","difference","balance"];
    }

    initialize(){ }

    connect(){
      console.log("connected");
      this.expectedTarget.value = this.data.get("expectedBalance");
    }

    removeModal(){
      $(this.element).modal("hide").remove();
    }

    updateDifference(){
      this.differenceTarget.value = this.balanceTarget.value - this.expectedTarget.value
    }


  });
})();

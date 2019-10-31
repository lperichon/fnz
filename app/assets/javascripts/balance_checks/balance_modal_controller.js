(()=>{
  stimulusApplication.register("balance_modal", class extends Stimulus.Controller {
    static get targets(){
      return ["expected","difference","balance"];
    }

    initialize(){ }

    connect(){
      this.expectedTarget.value = this.data.get("expectedBalance");
      this.avoidDoubleSubmission();
    }

    removeModal(){
      $(this.element).modal("hide").remove();
    }

    updateDifference(){
      this.differenceTarget.value = this.balanceTarget.value - this.expectedTarget.value
    }

    avoidDoubleSubmission(){
      console.log("bind avoidance");
      $("#new_balance_check").submit(()=>{
        console.log("disable");
        $("#submitBalanceCheck").attr("disabled","disabled");
      });
    }


  });
})();

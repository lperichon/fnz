(()=>{
  stimulusApplication.register("split_form", class extends Stimulus.Controller {
    static get targets(){
      return ["subFormula", "subAmount", "submit","errorMessage"];
    }

    initialize(){
    }

    connect(){
      this.validate();
    }

    validate(){
      console.log("validating...");
      if(this.amountsEqTotal()){
        this.enableForm();
      } else {
        this.disableForm();
      }
    }

    disableForm(){
      this.errorMessageTarget.innerHTML = this.data.get("errorMessage");
      this.errorMessageTarget.style = "display: inline";
      this.submitTarget.disabled = true;
      this.submitTarget.style = "display: none";
    }

    enableForm(){
      this.errorMessageTarget.innerHTML = "";
      this.errorMessageTarget.style = "display: none";
      this.submitTarget.disabled = false;
      this.submitTarget.style = "display: inline";
    }

    amountsEqTotal(){
      var expected = this.data.get("originalAmount");
      var total    = 0;
      this.subAmountTargets.forEach((i) => {
        total += parseFloat(i.value);
      });
      return expected == total;
    }
  });
})();

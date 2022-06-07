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
      this.log("validating...");
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

    updateLastFormula(){
      this.log("update")
      if (!this.amountsEqTotal()){
        let originalAmount = parseFloat(this.data.get("originalAmount"))
        let firstSubAmountValue = parseFloat(this.subAmountTargets[0].value)
        let lastSubFormula = this.subFormulaTargets[this.subFormulaTargets.length - 1]
        if (firstSubAmountValue < originalAmount) {
          lastSubFormula.value = originalAmount - firstSubAmountValue
        }
      }
      return true
    }

    amountsEqTotal(){
      var expected = this.data.get("originalAmount");
      var total    = 0;
      this.subAmountTargets.forEach((i) => {
        total += parseFloat(i.value);
      });
      return expected == total;
    }

    log(msg){
      console.log("[split_form] "+msg)
    }
  });
})();

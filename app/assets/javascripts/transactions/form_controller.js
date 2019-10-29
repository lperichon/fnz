(()=>{
  stimulusApplication.register("transaction_form", class extends Stimulus.Controller {
    static get targets(){
      return ["transactionTypeOption","transferField", "stateField"];
    }

    initialize(){ }

    updateFormFields(){
      var so = this.selectedTransactionOption();
      if(so){

        if(so.value=="Transfer"){
          $(".transfer_field").children().removeAttr("disabled");
          $(".transfer_field").show();
        } else {
          $(".transfer_field").children().attr("disabled",true);
          $(".transfer_field").hide();
        }

      }

      var state = this.stateFieldTarget.value;
      if(state){
        if(state == "reconciled"){
          $(".pending_field").children().removeAttr("disabled");
          $(".pending_field").show();
        } else {
          $(".pending_field").children().attr("disabled",true);
          $(".pending_field").hide();
        }
      }

    }

    selectedTransactionOption(){
      var selectedOptions = this.transactionTypeOptionTargets.filter((i)=>{ return i.checked; });
      if(selectedOptions.length>0){
        return selectedOptions[0];
      } else {
        return null;
      }
    }
  });
})();

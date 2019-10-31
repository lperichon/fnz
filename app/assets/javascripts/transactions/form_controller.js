(()=>{
  stimulusApplication.register("transaction_form", class extends Stimulus.Controller {
    static get targets(){
      return ["transactionTypeOption","transferField", "stateField","colorSignal","extraFieldsContainer","toggleButtonVerb"];
    }

    initialize(){
    }

    connect(){
      this.updateFormFields();
      this.updateColor();
      this.toggleExtraOptions();
      this.avoidDoubleSubmit();
    }

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

    toggleExtraOptions(){
      var el = this.extraFieldsContainerTarget;
      if(window.getComputedStyle(el).display == 'none'){
        this.toggleButtonVerbTarget.innerHTML = this.toggleButtonVerbTarget.dataset.hideMsg;
        el.style.display = "block";
      } else {
        this.toggleButtonVerbTarget.innerHTML = this.toggleButtonVerbTarget.dataset.showMsg;
        el.style.display = "none";
      }
      return el;
    }

    updateColor(){
      if(this.hasColorSignalTarget){
        var so = this.selectedTransactionOption();
        if(so){
          var color = "";
          switch(so.value){
            case "Transfer":
              color = "";
              break;
            case "Debit":
              color = "red";
              break;
            case "Credit":
              color = "green";
              break;
          }
          this.colorSignalTarget.style="background-color: "+color+";";
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

    avoidDoubleSubmit(){
      $("#new_transaction").submit(()=>{
        $("#submitTransaction").attr("disabled","disabled");
      });
    }
  });
})();

(()=>{
  stimulusApplication.register("transaction-form", class extends Stimulus.Controller {
    static get targets(){
      return [
        "transactionTypeOption",
        "transferField",
        "stateField",
        "colorSignal",
        "extraFieldsContainer",
        "toggleButtonVerb",
        "sourceAccount",
        "targetAccount",
        "conversionRateField"
      ];
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
      if(this.hasExtraFieldsContainerTarget){
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

    updateConversionRate(){
      this.log("updating conversion rate")
      let fromCur = this.sourceAccountTarget.selectedOptions[0].dataset.currency
      let toCur = this.targetAccountTarget.selectedOptions[0].dataset.currency
      let refDate = this.selectedReportAt()
      if (fromCur && toCur && refDate) {
        fetch(this.data.get("ratesUrl")+"?from="+fromCur+"&to="+toCur+"&ref_date="+refDate, {
          method: 'GET',
          headers: {
            'Content-Type': 'application/json',
            'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
          }
        }).then(response => response.json())
          .then(data => {
            let rate = data["rate"]
            if (rate === null) {
              alert("error getting exchange rate")
              this.conversionRateFieldTarget.value = 1.0
            } else {
              this.conversionRateFieldTarget.value = rate
            }
          })
          .catch((error) => {
            alert(error)
            this.conversionRateFieldTarget.value = 1.0
          })
      }
    }

    selectedReportAt(){
      let day = $("#transaction_report_at_3i").val()
      let month = $("#transaction_report_at_2i").val()
      let year = $("#transaction_report_at_1i").val()
      return year + "-" + month + "-" + day
    }

    log(msg){
      console.log("[transaction-form]" + msg)
    }


  });
})();

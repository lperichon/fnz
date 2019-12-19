(()=>{
  stimulusApplication.register("sum_selected", class extends Stimulus.Controller {
    static get targets(){
      return ["selector","result","resultContainer","count"];
    }

    connect(){
    }

    showSubtotal(){
      this.resultContainerTarget.classList.toggle("sum_selected--no-subtotal",this.getSelectedVisible().length==0);
      this.showCount();
      this.resultTarget.innerText = this.sum();
    }

    showCount(){
      this.countTarget.innerText = this.getSelectedVisible().length;
    }


    sum(){
      var acum = 0;
      this.getSelectedVisible().map((el)=>{
        acum += this.valueFor(el);
      });
      return acum;
    }

    getSelectedVisible(){
      return this.selectorTargets.filter((el)=>{
        return (el.checked && !this.isHidden(el))
      });
    }

    isHidden(el) {
      return (el.offsetParent === null)
    }

    valueFor(selector){
      var tr = selector.parentElement.parentElement;
      var amountString = tr.querySelector("td:nth-child(4)").textContent

      // TODO no contempla euros etc
      amountString = amountString.trim().replace("$","").replace(".","").replace(",",".")
      return math.evaluate(amountString) * this.signFor(tr);
    }

    signFor(tr){
      if(tr.querySelector(".icon-credit")){
        return 1;
      } else if(tr.querySelector(".icon-debit")){
        return -1;
      } else {
        return 0;
      }
    }


  });

})();

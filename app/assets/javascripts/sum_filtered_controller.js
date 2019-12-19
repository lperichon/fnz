(()=>{
  stimulusApplication.register("sum_filtered", class extends Stimulus.Controller {
    static get targets(){
      return ["row","result","resultContainer","count"];
    }

    connect(){
    }

    showSubtotal(){
      this.resultContainerTarget.classList.toggle("sum_filtered--no-subtotal",this.getVisible().length==0);
      this.showCount();
      this.resultTarget.innerText = this.sum();
    }

    showCount(){
      this.countTarget.innerText = this.getVisible().length;
    }


    sum(){
      var acum = 0;
      this.getVisible().map((el)=>{
        acum += this.valueFor(el);
      });
      return acum;
    }

    getVisible(){
      return this.rowTargets.filter((el)=>{
        return !this.isHidden(el);
      });
    }

    isHidden(el) {
      return (el.offsetParent === null)
    }

    valueFor(row){
      var amountString = row.querySelector("td:nth-child(4)").textContent

      // TODO no contempla euros etc
      amountString = amountString.trim().replace("$","").replace(".","").replace(",",".")
      return math.evaluate(amountString) * this.signFor(row);
    }

    signFor(row){
      if(row.querySelector(".icon-credit")){
        return 1;
      } else if(row.querySelector(".icon-debit")){
        return -1;
      } else {
        return 0;
      }
    }


  });

})();

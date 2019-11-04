(()=>{
  stimulusApplication.register("calculator", class extends Stimulus.Controller {
    static get targets(){
      return ["formula","result"];
    }

    calculateResult(){
      var result = null;
      try {
        result = math.evaluate(this.formulaTarget.value);
      } catch (err) {
        // do nothing
      }
      if(result !== null){
        this.resultTargets.forEach((i) => {
          i.value = result;
        });
      }
    }
  });
})();

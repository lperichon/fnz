(()=>{
  stimulusApplication.register("transactions_search", class extends Stimulus.Controller {
    static get targets(){
      return ["form", "fieldsContainer"];
    }

    initialize(){
      console.log("init")
    }
    connect(){
      console.log("connect")
      $(this.fieldsContainerTarget).hide()
      let items = this.formTarget.getElementsByClassName("chosen")
      for (let ch of items) {
        $(ch).chosen()
      }
    }

    toggleFields(e){
      e.preventDefault() // dont submit form
      if(this.fieldsContainerTarget.style.display == "none") {
        $(this.fieldsContainerTarget).show()
      } else {
        $(this.fieldsContainerTarget).hide()
      }
    }

  });
})();

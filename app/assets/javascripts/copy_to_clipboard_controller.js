/* global Stimulus */
/* global $ */
(() => {
  stimulusApplication.register("CopyToClipboard", class extends Stimulus.Controller {

    static get targets(){
      return ["source"];
    }
    
    initialize(){
    }

    copy(e){
      this.sourceTarget.style.display = "inline";
      this.sourceTarget.select();
      document.execCommand('copy')
      this.sourceTarget.style.display = "none";
      alert(this.copiedMsg());
    }

    copiedMsg(){
      if(this.data.get("success-message")){
        return this.data.get("success-message");
      } else {
        return "copied to clipboard";
      }
    }

  });

})();

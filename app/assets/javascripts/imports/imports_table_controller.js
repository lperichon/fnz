(()=>{
  stimulusApplication.register("imports_table", class extends Stimulus.Controller {
    static get targets(){
      return ["archiveBtn","recoverBtn"];
    }

    initialize(){
    }

    connect(){
      this.bindArchiveBtns();
      this.bindRecoverBtns();
    }

    bindArchiveBtns(){
      this.archiveBtnTargets.forEach((i)=>{
        $(i).on("ajax:complete",()=>{
          $($(i).closest("tr")).hide();
        });
      });
    }
    bindRecoverBtns(){
      this.recoverBtnTargets.forEach((i)=>{
        $(i).on("ajax:complete",()=>{
          location.reload();
        });
      });
    }

  });
})();

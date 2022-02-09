(()=>{
  stimulusApplication.register("sidebar", class extends Stimulus.Controller {

    static get targets(){
      return ["sidebar","body","toggler","togglerVerb"];
    }

    connect(){
      if(this.hasTogglerVerbTarget && this.hasTogglerTarget){
        // sideBar starts visible
        this.togglerVerbTarget.innerHTML = this.togglerTarget.dataset.hideMsg;

        if(this.readCookieState() == "hidden"){
          this.hideSideBar();
        }
      }
    }

    sideBarIsHidden(){
      return this.sidebarTarget.style.display=="none";
    }

    toggleSideBar(){
      if(this.sideBarIsHidden()){
        this.showSideBar();
      } else {
        this.hideSideBar();
      }
    }

    hideSideBar(){
      this.sidebarTarget.style.display = "none";
      $(this.bodyTarget).toggleClass("span9").toggleClass("span12").toggleClass("stickLeft");
      this.togglerVerbTarget.innerHTML = this.togglerTarget.dataset.showMsg;

      document.cookie = "sidebar=hidden";
    }

    showSideBar(){
      $(this.bodyTarget).toggleClass("span9").toggleClass("span12").toggleClass("stickLeft");
      this.sidebarTarget.style.display="block";
      this.togglerVerbTarget.innerHTML = this.togglerTarget.dataset.hideMsg;
      document.cookie = "sidebar=visible";
    }

    readCookieState(){
      var cookie = document.cookie.split(";").filter((c)=>{ return c.match("sidebar") })[0];
      if(cookie){
        cookie.indexOf("=");
        return cookie.substring(cookie.indexOf("=")+1,cookie.length);
      }
    }

  });
})();

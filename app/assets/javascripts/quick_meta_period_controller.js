(()=>{
  stimulusApplication.register("quick_meta_filter", class extends Stimulus.Controller {
    static get targets(){
      return ["selector"];
    }

    initialize(){

    }
    connect(){

    }
    disconnect(){

    }

    goToPeriod(event){
      let metaPeriod = this.selectorTarget.value
      let start = null
      let end = null
      switch (metaPeriod) {
        case "current_month":
          start = moment().startOf("month")
          end = moment().endOf("month")

          break
        case "previous_month":
          start = moment().subtract(1, "month").startOf("month")
          end = moment().subtract(1, "month").endOf("month")
          break
        case "month_before_last":
          start = moment().subtract(2, "month").startOf("month")
          end = moment().subtract(2, "month").endOf("month")
          break
      }
      if (start && end) {
        window.location = "?meta_period="+metaPeriod+"&start_date=" + start.format("YYYY-M-D") + "&end_date=" + end.format("YYYY-M-D")
      }
    }
  });

})();

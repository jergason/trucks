var TruckPricer = {

  makeRequestParams : function() {
    var modelId = $("[name='truck_model_id']").val();
    var engineId = $("[name='engine_id']").val();
    var yearId = $("[name='year_id']").val();
    var price = $("[name='price']").val();
    if (price === "") {
      price = "0.00";
    }
    var request = {
      "engine_id" : engineId,
      "truck_model_id" : modelId,
      "year_id" : yearId,
      "price" : price
    };
    return request;
  },

  getTruckPrice : function(event) {
    $("#message").text("");
    var request = this.makeRequestParams();
    $.get("/price", request, function(response) {
      if (response.error === false) {
        $("[name='price']").val(response.price);
      }
      else {
        $("[name='price']").val("No price yet");
      }
      $("#message").text(response.message);
    }, "json");
  },

  setTruckPrice : function(event) {
    var request = this.makeRequestParams();
    //$.post("/price", request, function(response) {
      //$("#message").val(response.message);
    //}, "json");
    $.ajax({
      url: "/price",
      type: "POST",
      data: request,
      dataType: "json",
      cache: false,
      success: function(response, status, xhr) {
        $("#message").text(response.message);
      },
      error: function (xhr, status, exception) {
        console.error("Error in setTruckPrice ajax request!");
        console.debug("status is " + status);
        console.debug("xhr is " + xhr);
      }
    });
  }

};

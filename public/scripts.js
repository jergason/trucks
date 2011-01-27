var TruckPricer = {
  getTruckPrice : function(event) {
    var request = this.makeRequestParams();
    $.get("/price", request, function(response) {
      if (response.error === false) {
        $("[name='price']").val(response.price);
      }
      $("#message").val(response.message);
    }, "json");
  },

  setTruckPrice : function(event) {
    var request = this.makeRequestParams();
    $.post("/price", request, function(response) {
    }, "json");
  },

  makeRequestParams : function() {
    var modelId = $("[name='truck_model']").val();
    var engineId = $("[name='engine']").val();
    var yearId = $("[name='year']").val();
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
  }
};

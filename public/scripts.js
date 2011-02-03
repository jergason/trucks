var TruckPricer = {

  makeRequestParams : function() {
    var modelId = $("[name='truck_model_id']").val();
    var engineId = $("[name='engine_id']").val();
    var yearId = $("[name='year_id']").val();
    var price = $("[name='price']").val();
    var mileage_cutoff = $("[name='mileage_cutoff']").val();
    var price_per_mile = $("[name='price_per_mile']").val();
    var price_per_mile_after_cutoff = $("[name='price_per_mile_after_cutoff']").val();
    if (price === "") {
      price = "0.00";
    }
    if (mileage_cutoff === "") {
      mileage_cutoff = "0";
    }
    if (price_per_mile === "") {
      price_per_mile = "0.00";
    }
    if (price_per_mile_after_cutoff === "") {
      price_per_mile_after_cutoff = "0.00";
    }
    var request = {
      "engine_id" : engineId,
      "truck_model_id" : modelId,
      "year_id" : yearId,
      "price" : price,
      "mileage_cutoff" : mileage_cutoff,
      "price_per_mile" : price_per_mile,
      "price_per_mile_after_cutoff" : price_per_mile_after_cutoff
    };
    return request;
  },

  getTruckPrice : function(event) {
    $("#form_message").text("");
    var request = this.makeRequestParams();
    $.get("/price", request, function(response) {
      if (response.error === false) {
        $("[name='price']").val(response.price);
        $("[name='mileage_cutoff']").val(response.mileage_cutoff);
        $("[name='price_per_mile']").val(response.price_per_mile);
        $("[name='price_per_mile_after_cutoff']").val(response.price_per_mile_after_cutoff);
      }
      else {
        $("[name='price']").val("No price yet");
        $("[name='mileage_cutoff']").val("No cutoff yet");
        $("[name='price_per_mile']").val("No price per mile yet");
        $("[name='price_per_mile_after_cutoff']").val("no price per mile after cutoff yet");
      }
      $("#form_message").text(response.message);
      $("#form_message").show();
    }, "json");
  },

  setTruckPrice : function(event) {
    var request = this.makeRequestParams();
    $.ajax({
      url: "/price",
      type: "POST",
      data: request,
      dataType: "json",
      cache: false,
      success: function(response, status, xhr) {
        $("#form_message").text(response.message);
      },
      error: function (xhr, status, exception) {
        console.error("Error in setTruckPrice ajax request!");
        console.debug("status is " + status);
        console.debug("xhr is " + xhr);
      }
    });
  }

};

var TruckPricer = {

  makeRequestParams : function() {
    var modelId = $("[name='truck_model_id']").val();
    var engineId = $("[name='engine_id']").val();
    var yearId = $("[name='year_id']").val();
    var price = $("[name='price']").val();
    var mileage_cutoff = $("[name='mileage_cutoff']").val();
    var second_mileage_cutoff = $("[name='second_mileage_cutoff']").val();
    var add_per_mile = $("[name='add_per_mile']").val();
    var deduct_per_mile = $("[name='deduct_per_mile']").val();
    var second_deduct_per_mile = $("[name='second_deduct_per_mile']").val();
    var extra_deduct = $("[name='extra_deduct']").val();
    if (price === "") {
      price = "0.00";
    }
    if (mileage_cutoff === "") {
      mileage_cutoff = "0";
    }
   if (second_mileage_cutoff === "") {
      second_mileage_cutoff = "0";
    }
    if (add_per_mile === "") {
      add_per_mile = "0.00";
    }
    if (deduct_per_mile === "") {
      deduct_per_mile = "0.00";
    }
    if (second_deduct_per_mile === "") {
      second_deduct_per_mile = "0.00";
    }
    if (extra_deduct === "") {
      extra_deduct = "0.00";
    }

    var request = {
      "engine_id" : engineId,
      "truck_model_id" : modelId,
      "year_id" : yearId,
      "price" : price,
      "mileage_cutoff" : mileage_cutoff,
      "second_mileage_cutoff" : second_mileage_cutoff,
      "add_per_mile" : add_per_mile,
      "deduct_per_mile" : deduct_per_mile,
      "second_deduct_per_mile": second_deduct_per_mile,
      "extra_deduct": extra_deduct
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
        $("[name='second_mileage_cutoff']").val(response.second_mileage_cutoff);
        $("[name='add_per_mile']").val(response.add_per_mile);
        $("[name='deduct_per_mile']").val(response.deduct_per_mile);
        $("[name='second_deduct_per_mile']").val(response.second_deduct_per_mile);
        $("[name='extra_deduct']").val(response.extra_deduct);
      }
      else {
        $("[name='price']").val("No price yet");
        $("[name='mileage_cutoff']").val("No cutoff yet");
        $("[name='second_mileage_cutoff']").val("No second cutoff yet");
        $("[name='add_per_mile']").val("No price per mile yet");
        $("[name='deduct_per_mile']").val("No price per mile after cutoff yet");
        $("[name='second_deduct_per_mile']").val("No price per mile after second cutoff yet");
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

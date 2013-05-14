// # Place all the behaviors and hooks related to the matching controller here.
// # All this logic will automatically be available in application.js.
// # You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
var map;
var heatmap;
var mapData;

window.onload = function(){
  var myLatlng = new google.maps.LatLng(40.4230, -98.7372);

  var myOptions = {
    zoom: 3,
    center: myLatlng,
    mapTypeId: google.maps.MapTypeId.ROADMAP,
    disableDefaultUI: false,
    scrollwheel: true,
    draggable: true,
    navigationControl: true,
    mapTypeControl: false,
    scaleControl: true,
    disableDoubleClickZoom: false
  };

	map = new google.maps.Map(document.getElementById("heatmapArea"), myOptions);
  heatmap = new HeatmapOverlay(map, {"radius":10, "visible":true, "opacity":60});

  var geocoded_clicks_path = "/home/geocoded_clicks"

  if ($('#pixel_data').length > 0){
	  geocoded_clicks_path = $('#pixel_data').attr('data-geo-path')
  }
  console.log(geocoded_clicks_path)
  $.ajax({
    type: "GET",
    dataType: "json",
    url: geocoded_clicks_path,
    success: function(data){ 
      mapData={
        max: 46,
        data: data
      };
    }
  });
	google.maps.event.addListenerOnce(map, "idle", function(){
    heatmap.setDataSet(mapData);
  });
};
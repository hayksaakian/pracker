// # Place all the behaviors and hooks related to the matching controller here.
// # All this logic will automatically be available in application.js.
// # You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$(document).ready(function() { 
  if ($('#chart').length > 0) {
    // console.log(chart_opts)
    Highcharts.setOptions({
        chart: {
            backgroundColor: {
                linearGradient: [500, 500, 0, 0],
                stops: [
                    [0, 'rgb(255, 255, 255)'],
                    [1, 'rgb(240, 240, 255)']
                ]
            },
            plotBackgroundColor: 'rgba(255, 255, 255, .9)',
            plotShadow: true,
            plotBorderWidth: 1
        }
    });

    var chart1 = new Highcharts.Chart({
        chart: {
            renderTo: 'chart'
        },
        title: {
            text: 'Hits over Time'
        },
        xAxis: {
            categories: chart_opts['categories']
        },
        yAxis: {
            title: {
                text: ''
            }
        },
        series: [{
            name: 'Total Hits',
            data: chart_opts['series'][0]
          },{
            name: 'Total Clicks',
            data: chart_opts['series'][1]
          }
        ]
    });    
  };
});
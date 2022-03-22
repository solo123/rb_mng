var dt;
$(document).ready(function() {

  Highcharts.getJSON('http://localhost:3000/v1/test/demo.dat', function (data) {
    // Create the chart
    dt = data;
    Highcharts.stockChart('container', {
        rangeSelector: {
            selected: 1
        },

        title: {
            text: '我的数据'
        },

        series: [{
            name: '指标1',
            data: data,
            tooltip: {
                valueDecimals: 2
            }
        }]
    });
  });
});
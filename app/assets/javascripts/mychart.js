// Build the chart
function show_pie_chart(chartid, title, data)
{
    $('#'+chartid).highcharts({
        colors: ['#c12e34','#e6b600','#0098d9','#2b821d',
            '#005eaa','#339ca8','#cda819','#32a487',
            '#50B432', '#ED561B', '#DDDF00', '#24CBE5',
            '#64E572', '#FF9655', '#FFF263', '#6AF9C4'],
        title: {
            text: title
        },
        tooltip: {
            pointFormat: '占比：<b>{point.percentage:.1f}%</b><br/>值：<b>{point.y}%</b>'
        },
        legend: {
            enabled: true,
            layout: 'vertical',
            align: 'right',
            verticalAlign: 'middle',
            labelFormatter: function() {
                return this.name + ' ' + this.y;
            }
        },
        plotOptions: {
            pie: {
                allowPointSelect: true,
                cursor: 'pointer',
                dataLabels: {
                    enabled: false
                },
                showInLegend: true
            }
        },
        series: [{
            type: 'pie',
            data: data
        }]
    });
}
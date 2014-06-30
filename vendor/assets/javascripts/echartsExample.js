var myChart;
var domMain = document.getElementById('main');

function refresh(){
  option = {
    title : {
      text: '政府网站分布图',
      subtext: '纯属虚构',
      x:'center'
    },
    tooltip : {
      trigger: 'item'
    },
   dataRange: {
      min: 0,
      max: 2500,
      text:['高','低'],           // 文本，默认为数值文本
      calculable : true,
      textStyle: {
        color: 'orange'
      }
    },
    /*
     legend: {
      orient: 'vertical',
      x:'left',
      data:['iphone3']
    },
    toolbox: {
      show : true,
      orient : 'vertical',
      x: 'right',
      y: 'center',
      feature : {
        mark : true,
        dataView : {readOnly: false},
        restore : true,
        saveAsImage : true
      }
    },
   */
    series : [
      {
      name: 'iphone3',
      type: 'map',
      mapType: 'china',
      itemStyle:{
        normal:{label:{show:true}, color:'#ffd700'},// for legend
        emphasis:{label:{show:true}}
      },
      data:[
        {name: '北京',value: Math.round(Math.random()*1000)},
        {name: '天津',value: Math.round(Math.random()*1000)},
        {name: '上海',value: Math.round(Math.random()*1000)},
        {name: '重庆',value: Math.round(Math.random()*1000)},
        {name: '河北',value: Math.round(Math.random()*1000)},
        {name: '河南',value: Math.round(Math.random()*1000)},
        {name: '云南',value: Math.round(Math.random()*1000)},
        {name: '辽宁',value: Math.round(Math.random()*1000)},
        {name: '黑龙江',value: Math.round(Math.random()*1000)},
        {name: '湖南',value: Math.round(Math.random()*1000)},
        {name: '安徽',value: Math.round(Math.random()*1000)},
        {name: '山东',value: Math.round(Math.random()*1000)},
        {name: '新疆',value: Math.round(Math.random()*1000)},
        {name: '江苏',value: Math.round(Math.random()*1000)},
        {name: '浙江',value: Math.round(Math.random()*1000)},
        {name: '江西',value: Math.round(Math.random()*1000)},
        {name: '湖北',value: Math.round(Math.random()*1000)},
        {name: '广西',value: Math.round(Math.random()*1000)},
        {name: '甘肃',value: Math.round(Math.random()*1000)},
        {name: '山西',value: Math.round(Math.random()*1000)},
        {name: '内蒙古',value: Math.round(Math.random()*1000)},
        {name: '陕西',value: Math.round(Math.random()*1000)},
        {name: '吉林',value: Math.round(Math.random()*1000)},
        {name: '福建',value: Math.round(Math.random()*1000)},
        {name: '贵州',value: Math.round(Math.random()*1000)},
        {name: '广东',value: Math.round(Math.random()*1000)},
        {name: '青海',value: Math.round(Math.random()*1000)},
        {name: '西藏',value: Math.round(Math.random()*1000)},
        {name: '四川',value: Math.round(Math.random()*1000)},
        {name: '宁夏',value: Math.round(Math.random()*1000)},
        {name: '海南',value: Math.round(Math.random()*1000)},
        {name: '台湾',value: Math.round(Math.random()*1000)},
        {name: '香港',value: Math.round(Math.random()*1000)},
        {name: '澳门',value: Math.round(Math.random()*1000)}
      ]
    },
    ]
  };

  myChart.setOption(option, true);
}

function needMap() {
  return true;
  var href = location.href;
  return href.indexOf('map') != -1
    || href.indexOf('mix3') != -1
      || href.indexOf('mix5') != -1;

}

var echarts;
var developMode = true;

if (developMode) {
  // for develop
  require.config({
    packages: [
      {
      name: 'echarts',
      location: '/assets/echarts',
      main: 'echarts'
    },
    {
      name: 'zrender',
      //location: 'http://ecomfe.github.io/zrender/src',
      location: '/assets/zrender',
      main: 'zrender'
    }
    ]
  });
}
else {
  // for echarts online home page
  var fileLocation = needMap() ? './www/js/echarts-map' : './www/js/echarts';
  require.config({
    paths:{ 
      echarts: fileLocation,
      'echarts/chart/line': fileLocation,
      'echarts/chart/bar': fileLocation,
      'echarts/chart/scatter': fileLocation,
      'echarts/chart/k': fileLocation,
      'echarts/chart/pie': fileLocation,
      'echarts/chart/radar': fileLocation,
      'echarts/chart/map': fileLocation,
      'echarts/chart/chord': fileLocation,
      'echarts/chart/force': fileLocation
    }
  });
}

// 按需加载
require(
  [
  'echarts',
  'echarts/chart/line',
  'echarts/chart/bar',
  'echarts/chart/scatter',
  'echarts/chart/k',
  'echarts/chart/pie',
  'echarts/chart/radar',
  'echarts/chart/force',
  'echarts/chart/chord',
  needMap() ? 'echarts/chart/map' : 'echarts'
],
requireCallback
);

function requireCallback (ec) {
  echarts = ec;
  if (myChart && myChart.dispose) {
    myChart.dispose();
  }
  myChart = echarts.init(domMain);
  refresh();
  window.onresize = myChart.resize;
}

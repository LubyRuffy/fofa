
var DataSourceTree = function(options) {
    this._data 	= options.data;
    this._delay = options.delay;
}

DataSourceTree.prototype.data = function(options, callback) {
    var self = this;
    var $data = null;

    if(!("name" in options) && !("type" in options)){
        $data = this._data;//the root tree
        callback({ data: $data });
        return;
    }
    else if("type" in options && options.type == "folder") {
        if("additionalParameters" in options && "data" in options)
            $data = options.data;
        else $data = {}//no data
    }

    if($data != null)//this setTimeout is only for mimicking some random delay
        callback({ data: $data });

    //we have used static data here
    //but you can retrieve your data dynamically from a server using ajax call
    //checkout examples/treeview.html and examples/treeview.js for more info
};

var is_refresh_domains=false;
var is_refresh_assets_host=false;
var is_refresh_assets_ip=false;
var is_refresh_assets_person=false;

function refresh_domains(target_id)
{
    is_refresh_domains = true;
    $.getScript("/my/targets/"+target_id+"/asset_domains/reload.js",function() {
        is_refresh_domains = false;
    });
}

function set_type_refresh(type, is_refreshing)
{
    if(type=='host')
        is_refresh_assets_host=is_refreshing;
    else if(type=='ip')
        is_refresh_assets_ip=is_refreshing;
    else if(type=='person')
        is_refresh_assets_person=is_refreshing;
}

function refresh_assets_from_data(treeid, data)
{
    if ($('#'+treeid).data().tree)
        delete($('#'+treeid).data().tree);

    $('#'+treeid+'Panel').html(
        '<div id="'+treeid+'" class="tree tree-plus-minus tree-solid-line tree-unselectable">\
    <div class = "tree-folder" style="display:none;"> \
        <div class="tree-folder-header">\
            <i class="fa fa-folder"></i>\
            <div class="tree-folder-name"></div>\
        </div>\
        <div class="tree-folder-content"></div>\
        <div class="tree-loader" style="display:none"></div>\
    </div>\
    <div class="tree-item" style="display:none;">\
        <i class="tree-dot"></i>\
        <div class="tree-item-name"></div>\
    </div>\
</div>');
    var treedata = new DataSourceTree({
        data: data,
        delay: 10
    });

    $('#'+treeid).tree({
        selectable: false,
        dataSource: treedata,
        loadingHTML: '<i class="fa fa-refresh fa-spin mg-r-xs"></i>加载中……',
    });
}

//type = host,ip,person
function _refresh_assets(asset_type,target_id)
{
    set_type_refresh(asset_type, true);
    $('#'+asset_type+'s-size').html('<i class="fa fa-refresh fa-spin mg-r-xs"></i>');
    $.ajax({
        type: 'GET',
        url: '/my/targets/'+target_id+'/asset_'+asset_type+'s/get_all_json',
        success: function(data){
            if (data.error)
            {
                $('#ajaxLog').append("<font color='red'>"+data.errmsg+"</font><br/>");
            }
            else
            {
                treeid = asset_type+'Tree';
                if ($('#'+treeid).data().tree)
                    delete($('#'+treeid).data().tree);

                refresh_assets_from_data(treeid, data.data);

                $('#'+asset_type+'s-size').html(data.size);
            }
            set_type_refresh(asset_type, false);
        },
        error: function(e) {
            $('#ajaxLog').append("<font color='red'>error</font><br/>");
            set_type_refresh(asset_type, false);
        },
        dataType: 'json'
    });
}


function refresh_assets(asset_type,target_id)
{
    $.getScript("/my/targets/"+target_id+"/asset_"+asset_type+"s/reload.js?tree=true");
}

function refresh_progress(target_id)
{
    if(!is_refresh_domains && !is_refresh_assets_host
        && !is_refresh_assets_ip
        && !is_refresh_assets_person) {
        refresh_domains(target_id);
        refresh_assets('host', target_id);
        refresh_assets('ip', target_id);
        refresh_assets('person', target_id);
    }

    if (!$('#task_panel').is(':hidden'))
    {
        setTimeout("refresh_progress(<%= @target.id %>)", 5000);
    }

}

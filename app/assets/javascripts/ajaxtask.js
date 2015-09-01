//onclick='StartJob("/lab/domains/", "abc.com", function(){}, function(){}, function(data){})'
function StartJob(taskdata, jobFinished, onError, onData) {
    var $last_msgs = new Array();
    var $get_cnt = 0;
    var $has_data = false;

    Array.prototype.newdata = function(a) {
        return this.slice(a.length);
    };

    function pollJob(jobId, successCallback) {
        function poll() {
            var pollEvery = 2000; // milliseconds
            $.ajax({
                type: "GET",
                url: "/lab/gettask?jobId=" + jobId +"&t="+new Date().getTime(), // coupled to your app's routes
                dataType: 'json',
                statusCode: {
                    200: function (data) {
                        $get_cnt++;

                        var newdata = data.msgs.newdata($last_msgs);
                        if (newdata.length>0)
                        {
                            $last_msgs = data.msgs;
                            $has_data = true;
                            onData(newdata);
                        }

                        if ($has_data || $get_cnt<10)
                        {
                            if($get_cnt>60)
                            {
                                onError('任务超时，请稍后再试！');
                            }
                            else
                            {
                                if(!data.finished)
                                {
                                    setTimeout(poll, pollEvery);
                                }
                            }
                        }
                        else
                        {
                            onError('任务超时或者添加任务失败，请稍后再试！');
                        }

                        if(data.finished)
                        {
                            successCallback(data);
                        }
                    },
                    404: function (data) {
                        onError('Error!');
                    },
                    500: function (data) {
                        onError('Error!');
                    }
                }
            });
        };
        poll();
    }

    $.ajax({
        type: "POST",
        url: "/lab/addtask/",
        data: taskdata,
        dataType: 'json',
        success: function(data) {
            if (data.error)
                onError(data.errormsg);
            else
                pollJob(data.jobId, jobFinished);
        }
    });

}

function StartDump(jobId, jobFinished, onError, onData, need_submit) {
    var $last_msgs = new Array();
    var $get_cnt = 0;
    var $has_data = false;

    Array.prototype.newdata = function(a) {
        return this.slice(a.length);
    };

    function pollJob(jobId, successCallback) {
        function poll() {
            var pollEvery = 2000; // milliseconds
            $.ajax({
                type: "GET",
                url: "/my/targets/getdumpinfo?id=" + jobId +"&t="+new Date().getTime(), // coupled to your app's routes
                dataType: 'json',
                statusCode: {
                    200: function (data) {
                        $get_cnt++;

                        if (data.msgs.size==0 && data.finished)
                            successCallback(data);

                        var newdata = data.msgs.newdata($last_msgs);
                        if (newdata.length>0)
                        {
                            $last_msgs = data.msgs;
                            $has_data = true;
                            onData(newdata);
                        }

                        if ($has_data || $get_cnt<10)
                        {
                            if($get_cnt>60)
                            {
                                onError('任务超时，请稍后再试！');
                            }
                            else
                            {
                                if(!data.finished)
                                {
                                    setTimeout(poll, pollEvery);
                                }
                            }
                        }
                        else
                        {
                            onError('任务超时或者添加任务失败，请稍后再试！');
                        }

                        if(data.finished)
                        {
                            successCallback(data);
                        }
                    },
                    404: function (data) {
                        onError('Error!');
                    },
                    500: function (data) {
                        onError('Error!');
                    }
                }
            });
        };
        poll();
    }


    if (need_submit)
    {
        $.ajax({
            type: "GET",
            url: "/my/targets/adddumptask?id=" + jobId + "&t="+new Date().getTime(),
            dataType: 'json',
            success: function(data) {
                if (data.error)
                    onError(data.errormsg);
                else
                    pollJob(jobId, jobFinished);
            }
        });
    }
    else {
        pollJob(jobId, jobFinished);
    }

}


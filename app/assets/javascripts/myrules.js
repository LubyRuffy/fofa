
$(document).ready(function () {
    $('#validate').bootstrapValidator({
        feedbackIcons: {
            valid: 'glyphicon glyphicon-ok',
            invalid: 'glyphicon glyphicon-remove',
            validating: 'glyphicon glyphicon-refresh'
        },
        fields: {
            'rule[producturl]': {
                validators: {
                    uri: {
                        message: '网站格式不正确!'
                    }
                }
            },
            'rule[rule]': {
                validators: {
                    notEmpty: {
                        message: '规则文本必须填写！'
                    }
                }
            },
            'rule[product]': {
                validators: {
                    notEmpty: {
                        message: '给规则命个名吧！'
                    }
                }
            }
        }
    });
});
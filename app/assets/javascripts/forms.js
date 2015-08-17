$(document).ready(function() {
    var green = document.querySelector('.js-switch');
    var switchery = new Switchery(green, {
        color: '#2dcb73'
    });
    //var elems = Array.prototype.slice.call(document.querySelectorAll('.js-switch'));
    var blue = document.querySelector('.js-switch-blue');
    var switchery = new Switchery(blue, {
        color: '#17c3e5'
    });
    var pink = document.querySelector('.js-switch-pink');
    var switchery = new Switchery(pink, {
        color: '#ff7791',
        disabled: true
    });
    var green = document.querySelector('.js-switch-green');
    var switchery = new Switchery(green, {
        color: '#2dcb73'
    });
    var red = document.querySelector('.js-switch-red');
    var switchery = new Switchery(red, {
        color: '#FF604F'
    });
    var secondary = document.querySelector('.js-switch-secondary');
    var switchery = new Switchery(secondary, {
        color: '#FFB244',
        secondaryColor: '#ff8787'
    });
    $('.sliders input').slider();
    $('.datepicker').datepicker();
    function initToolbarBootstrapBindings() {
        var fonts = ['Serif', 'Sans', 'Arial', 'Arial Black', 'Courier', 'Courier New', 'Comic Sans MS', 'Helvetica', 'Impact', 'Lucida Grande', 'Lucida Sans', 'Tahoma', 'Times', 'Times New Roman', 'Verdana'], fontTarget = $('[title=Font]').siblings('.dropdown-menu');
        $.each(fonts, function(idx, fontName) {
            fontTarget.append($('<li><a data-edit="fontName ' + fontName + '" style="font-family:\'' + fontName + '\'">' + fontName + '</a></li>'));
        });
        $('a[title]').tooltip({
            container: 'body'
        });
        $('.dropdown-menu input').click(function() {
            return false;
        }).change(function() {
            $(this).parent('.dropdown-menu').siblings('.dropdown-toggle').dropdown('toggle');
        }).keydown('esc', function() {
            this.value = '';
            $(this).change();
        });
        $('[data-role=magic-overlay]').each(function() {
            var overlay = $(this), target = $(overlay.data('target'));
            overlay.css('opacity', 0).css('position', 'absolute').offset(target.offset()).width(target.outerWidth()).height(target.outerHeight());
        });
        if ("onwebkitspeechchange"in document.createElement("input")) {
            var editorOffset = $('#editor').offset();
        } else {
            $('#voiceBtn').hide();
        }
    };
    function showErrorAlert(reason, detail) {
        var msg = '';
        if (reason === 'unsupported-file-type') {
            msg = "Unsupported format " + detail;
        } else {
            console.log("error uploading file", reason, detail);
        }
        $('<div class="alert"> <button type="button" class="close" data-dismiss="alert">&times;</button>' + '<strong>File upload error</strong> ' + msg + ' </div>').prependTo('#alerts');
    };
    initToolbarBootstrapBindings();
    $('#editor').wysiwyg({
        fileUploadError: showErrorAlert
    });
});

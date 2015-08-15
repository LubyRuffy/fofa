// jQuery Plugin for SprFlat admin template
// Control options and basic function of template
// version 1.0, 28.02.2013
// by SuggeElson www.suggeelson.com

(function($) {

    // here we go!
    $.sprFlat = function(element, options) {

        // plugin's default options
        var defaults = {

            //main color scheme for template
            //be sure to be same as colors on main.css or custom-variables.less
            colors : {
                white: '#fff',
                dark: '#79859b',
                red: '#f68484',
                blue: '#75b9e6',
                green: '#71d398',
                yellow: '#ffcc66',
                orange: '#f4b162',
                purple: '#af91e1',
                pink: '#f78db8',
                lime: '#a8db43',
                mageta: '#eb45a7',
                teal: '#97d3c5',
                black: '#000',
                brown: '#d1b993',
                gray: '#f3f5f6'
            },
            customScroll: {
                color: '#999', //color of custom scroll
                railColor: '#eee', //color of rail
                size: '5px', //size in pixels
                opacity: '0.5', //opacity
                alwaysVisible: false //disable hide in
            },
            header: {
                fixed: true //fixed header
            },
            breadcrumbs: {
                auto: true //auto populate breadcrumbs via js if is false you need to provide own markup see for example.
            },
            sidebar: {
                fixed: true,//fixed sidebar
                rememberToggle: true //remember if sidebar is hided
            },
            sideNav : {
                hover: false, //shows subs on hover or click
                showNotificationNumbers: 'onhover',//show how many elements menu have with notifcation style values - always, onhover, never
                showArrows: true,//show arrow to indicate sub
                sideNavArrowIcon: 'en-arrow-down5', //arrow icon for navigation
                showIndicator: false,//show indicator when hover links
                notificationColor: 'red', //green, red
                subOpenSpeed: 300,//animation speed for open subs
                subCloseSpeed: 400,//animation speed for close subs
                animationEasing: 'linear',//animation easing
                absoluteUrl: false, //put true if use absolute path links. example http://www.host.com/dashboard instead of /dashboard
                subDir: '' //if you put template in sub dir you need to fill here. example '/html'
            },
            tile: {
                countNumbers: true //count numbers from 0 to specified value (required count plugin)
            },
            panels: {
                moveIcon: 'br-move',//move icon for panels
                refreshIcon: 'im-spinner6',//refresh icon for panels
                toggleIcon: 'im-minus',//toggle icon for panels
                collapseIcon: 'im-plus',//colapse icon for panels
                closeIcon: 'im-close', //close icon
                showControlsOnHover: true,//Show controls only on hover.
                overlayRefreshIcon: 'im-spinner5' //loading icon in overlay
            },
            lockMode : {
                active: false, //set false to disable lock mode
                autoLock: true, //Lock automatic in iddle
                minutes: 5 //how many minutes before lock mode is activate automatic
            },
            forms: {
                checkAndRadioTheme: 'blue', //theme for radios - aero, blue,flat, green,gray,orange,pink,purple,red,yellow
            },
            tooltips: true, //activate tooltip plugin build in bootstrap
            tables: {
                responsive: true, //make tables resposnive
                customscroll: true //ativate custom scroll for responsive tables
            },
            alerts: {
                animation: true, //animation effect toggle
                closeEffect: 'bounceOutDown' //close effect for alerts see http://daneden.github.io/animate.css/
            },
            backToTop: {
                active: true, //activate back to top
                scrolltime: 800, //scroll time speed
                imgsrc: 'assets/img/backtop.png', //image 
                width: 48, //width of image
                place: 'bottom-right', //position top-left, top-right, bottom-right, bottom-left
                fadein: 500, //fadein speed
                fadeout: 500, // fadeOut speed
                opacity: 0.5, //opacity
                marginX: 1, //X margin
                marginY: 2 //Y margin
            },
            dropdownMenu: {
                animation: true, //animation effect for dropdown
                openEffect: 'flipInY',//open effect for menu see http://daneden.github.io/animate.css/
            }

        }

        // current instance of the object
        var plugin = this;

        // this will hold the merged default, and user-provided options
        plugin.settings = {}

        var $element = $(element), // reference to the jQuery version of DOM element
            element = element;    // reference to the actual DOM element

        // the "constructor" method that gets called when the object is created
        plugin.init = function() {

            // the plugin's final properties are the merged default and 
            // user-provided options (if any)
            plugin.settings = $.extend({}, defaults, options);

            //activate transit plugin
            this.transit();

            // Delegate .transition() calls to .animate()
            // if the browser can't do CSS transitions.
            if (!$.support.transition) {
                $.fn.transition = $.fn.animate;
            }

            //respondjs handle responsive view
            this.respondjs();
            //activate storejs plugin
            this.storejs();
            //activate mousewheel plugin
            this.mouseWheel();
            //activate retina ready plugin
            this.retinaReady();
            //activate quicksearch plugin
            this.quickSearch();
            //sidebar nav
            this.sideBarNav();
            //set current class on nav
            this.setCurrentNav();
            //toggle sidebar
            this.toggleSidebar();
            //tile function
            this.tile();
            //handle panels
            this.panels();
            //handle accordions
            this.bsAccordion();
            //handle checkbox and radios theme
            this.checkAndRadios(plugin.settings.forms.checkAndRadioTheme);
            //toggle header area function
            this.toggleHeaderArea();
            //chat window basic functions
            this.chatWindow();

            //fixed header
            if(plugin.settings.header.fixed) {
                this.fixedHeader(true);
            }

            //fixed sidebar
            if(plugin.settings.sidebar.fixed) {
                this.fixedSidebar(true);
            }

            //check if sidebar need to be toggled
            if(plugin.settings.sidebar.rememberToggle) {
                var breakpoint = plugin.getBreakPoint();
                if(store.get('sidebarToggle') == 1 && breakpoint == 'large') {
                    plugin.hideLeftSidebar();
                }
            }

            //activate sortable layout
            this.sortable();

            //right sidebar toggle
            this.toggleRightSidebar();

            //tooltips
            if(plugin.settings.tooltips) {
                $('.tip-right').tooltip({
                    container: 'body',
                    placement: 'right'
                });
                $('.tip-bottom').tooltip({
                    container: 'body',
                    placement: 'bottom'
                });
                $('.tip-left').tooltip({
                    container: 'body',
                    placement: 'left'
                });
                $('.tip').tooltip({
                    container: 'body',
                    placement: 'top'
                });
            }

            //responsive tables
            if (plugin.settings.tables.responsive) {
                this.responsiveTables();
            }

            //alerts
            if (plugin.settings.alerts.animation) {
                $('.alert').bind('close.bs.alert', function () {
                    fullclass = 'animated '+ plugin.settings.alerts.closeEffect;
                    $(this).addClass(fullclass);
                })
            }

            //back to top
            if (plugin.settings.backToTop) {
                this.backToTop();
            }


            //call center modal function after modal is show
            $('.modal').on('show.bs.modal', function (e) {
                //center modal
                plugin.centerModal();
            })

            //update breadcrumbs
            if (plugin.settings.breadcrumbs.auto) {
                this.breadCrumbs();
            }

            //dropdown menu animations
            if(plugin.settings.dropdownMenu.animation) {
                this.dropdownMenuAnimations();
            }

            //todo basic functions
            this.toDoWidget();

            //hover direction plugin
            this.hoverDirection();

            //email ap
            this.emailApp();

            //------------- Click events -------------//
            //full screen
            $('a.full-screen').click(function(el) {
                plugin.launchFullScreen();
            });

            //------------- Resize evetns -------------//
            $(window).resize(function() {
                //center bootstrap modal
                plugin.centerModal();
            });
        }

        //get breakpoint
        plugin.getBreakPoint = function () {
            var jRes = jRespond([
                {
                    label: 'phone',
                    enter: 0,
                    exit: 767
                },{
                    label: 'tablet',
                    enter: 768,
                    exit: 979
                },{
                    label: 'laptop',
                    enter: 980,
                    exit: 1366
                },{
                    label: 'large',
                    enter: 1367,
                    exit: 10000
                }
            ]);

            return jRes.getBreakpoint();
        }

        // public methods
        //fixed header method
        plugin.fixedHeader = function (val) {
            if(val == true) {
                $('#header').addClass('header-fixed');
            } else {
                $('#header').removeClass('header-fixed');
            }
        }

        //fixed sidebar
        plugin.fixedSidebar = function (val) {
            if(val == true) {
                $('#sidebar').addClass('sidebar-fixed');
                //activate slim scroll
                $('#sidebar>.sidebar-inner').slimScroll({
                    position: "right",
                    height: '100%',
                    distance: '0',
                    railVisible: false,
                    size: plugin.settings.customScroll.size,
                    color: plugin.settings.customScroll.color,
                    railOpacity: plugin.settings.customScroll.opacity,
                    railColor: plugin.settings.customScroll.railColor
                });
            } else {
                $('#sidebar').removeClass('sidebar-fixed');
                //deactivate slim scroll
                $('.sidebar-inner').parent().replaceWith($('.sidebar-inner'));
                $('.sidebar-inner').attr('style', '');
            }
        }

        //toggle header area
        plugin.toggleHeaderArea = function () {
            var btn = $('#toggle-header-area');
            var btnIcon = btn.find('i');
            $(document).click(function(e) {
                if($(e.target).parent('#toggle-header-area').length > 0) {
                    $('#header-area').toggleClass('show-header-area animated');
                    if($('#header-area').hasClass('show-header-area')) {
                        btnIcon.transition({rotate: '-180deg'});
                    } else {
                        btnIcon.transition({rotate: '0deg'});
                    }
                    //need to parse actual width        
                    hw =  $('#header-area>').width();
                    hwbutton = $('.shortcut-button a').outerWidth();
                    elcount = $('#header-area>.header-area-inner>ul li').length +1;
                    actualWidht = hwbutton * elcount + elcount*2 + elcount*10 +30;
                    if (hw <= actualWidht) {
                        $('#header-area>.header-area-inner>.list-unstyled').css('width', actualWidht);
                    }
                    $('#header-area>.header-area-inner').slimScrollHorizontal({
                        size: plugin.settings.customScroll.size,
                        color: plugin.settings.customScroll.color,
                        railOpacity: plugin.settings.customScroll.opacity,
                        railColor: plugin.settings.customScroll.railColor,
                        width: '100%',
                        positon: 'bottom',
                        start: 'left',
                        railVisible: true,
                        distance: "0px",
                    });
                } else {
                    $('#header-area').removeClass('show-header-area');
                    btnIcon.transition({rotate: '0deg'});
                }
            });
        }

        //toggle sidebar
        plugin.toggleSidebar = function() {
            var toggleButton = $('#toggle-sidebar');
            var toggleIcon = toggleButton.find('i');
            var breakpoint = plugin.getBreakPoint();
            toggleButton.on("click", function(e){
                e.preventDefault();
                $('#sidebar').toggleClass('hide-sidebar');
                if (breakpoint == 'tablet' || breakpoint == 'phone') {
                    $('#content').toggleClass('full-page offCanvas');
                } else {
                    $('#content').toggleClass('full-page');
                }
                if($('#content').hasClass('full-page')) {
                    $('#content').removeClass('sidebar-page');
                    if (breakpoint == 'tablet' || breakpoint == 'phone') {
                        $('#content').removeClass('offCanvas');
                    }
                    toggleIcon.transition({rotate: '-180deg'});
                } else {
                    $('#content').addClass('sidebar-page');
                    toggleIcon.transition({rotate: '0deg'});
                }
                if(plugin.settings.sidebar.rememberToggle) {
                    if($('#sidebar').hasClass('hide-sidebar')) {
                        store.set('sidebarToggle', 1);
                    } else {
                        store.set('sidebarToggle', 0);
                    }
                }
            });
        }

        plugin.hideLeftSidebar = function() {
            var toggleButton = $('#toggle-sidebar');
            var toggleIcon = toggleButton.find('i');
            $('#sidebar').addClass('hide-sidebar');
            $('#content').addClass('full-page');
            $('#content').removeClass('sidebar-page');
            toggleIcon.transition({rotate: '-180deg'});
        }

        plugin.showLeftSidebar = function() {
            var toggleButton = $('#toggle-sidebar');
            var toggleIcon = toggleButton.find('i');
            $('#sidebar').removeClass('hide-sidebar');
            $('#content').removeClass('full-page');
            $('#content').addClass('sidebar-page');
            toggleIcon.transition({rotate: '0deg'});
        }

        //toggle right sidebar
        plugin.toggleRightSidebar = function() {
            var toggleButton = $('#toggle-right-sidebar');
            var breakpoint = plugin.getBreakPoint();
            toggleButton.on("click", function(e){
                e.preventDefault();
                $('#right-sidebar').toggleClass('hide-sidebar');
                if($('#content').hasClass('rightSidebar-page')) {
                    $('#content').removeClass('rightSidebar-page');
                } else {
                    $('#content').addClass('rightSidebar-page');
                }
            });
        }

        plugin.sideBarNav = function() {
            //cache the elements
            var navscroll = $('#sidebar>.sidebar-inner');
            var nav = $('#sideNav');
            var navCurrent = nav.find('li.current');
            var navLi = nav.find('li');
            var navLink = nav.find('a');
            var navSub = nav.find('li>ul.sub');

            //generate unique id for each link
            /*navLink.each(function(index) {
             $(this).attr('id', 'spr_menu_link_' + index);
             }); */

            if(plugin.settings.sideNav.showIndicator) {
                //put indicator for hover effect
                navLink.append('<span class="indicator">');
            }

            //put hasSub class
            navSub.closest('li').addClass('hasSub');
            //put notExpand class
            if(!navSub.prev('a').hasClass('notExpand')) {
                navSub.prev('a').addClass('notExpand');
            }

            if(plugin.settings.sideNav.showNotificationNumbers != 'never') {

                if(plugin.settings.sideNav.showNotificationNumbers == 'always') {
                    navSub.each(function(){
                        subItems = $(this).find('li').length;
                        if(!$(this).prev('a').find('span.notification').length){
                            $(this).prev('a').append('<span class="notification '+ plugin.settings.sideNav.notificationColor +'">' + subItems + '</span>');
                        }
                    })
                } else {
                    navSub.each(function(){
                        subItems = $(this).find('li').length;
                        if(!$(this).prev('a').find('span.notification').length){
                            $(this).prev('a').append('<span class="notification onhover '+ plugin.settings.sideNav.notificationColor +'">' + subItems + '</span>');
                        }
                    })
                }
            }

            if(plugin.settings.sideNav.showArrows) {
                if(!$('#sideNav').hasClass('show-arrows')) {
                    $('#sideNav').addClass('show-arrows');
                }
                if(!navSub.prev('a').find('i.sideNav-arrow').length) {
                    navSub.prev('a').prepend('<i class="'+ plugin.settings.sideNav.sideNavArrowIcon + ' sideNav-arrow"></i>');
                }
            }

            navLink.hover(
                function () {
                    //in 
                    if(plugin.settings.sideNav.showIndicator) {$(this).find('.indicator').transition({opacity:1}, 50);}
                },
                function () {
                    //out 
                    if(plugin.settings.sideNav.showIndicator) {$(this).find('.indicator').transition({opacity:0}, 0);}
                }
            );

            navLi.hover(
                function () {
                    //in 
                    _this = $(this).children('a');
                    if(plugin.settings.sideNav.hover) {
                        if(_this.hasClass('notExpand')) {
                            _this.next('ul').slideDown(plugin.settings.sideNav.subOpenSpeed, plugin.settings.sideNav.animationEasing);
                            _this.next('ul').addClass('show');
                            _this.addClass('expand').removeClass('notExpand');
                        }
                    }

                },
                function () {
                    //out 
                    _this = $(this).children('a');
                    if(plugin.settings.sideNav.hover) {
                        if (_this.hasClass('expand')) {
                            _this.next('ul').removeClass('show');
                            _this.next('ul').slideUp(plugin.settings.sideNav.subCloseSpeed, plugin.settings.sideNav.animationEasing);
                            _this.addClass('notExpand').removeClass('expand');
                        }
                    }
                }
            );

            if(!plugin.settings.sideNav.hover) {
                navLink.on("click", function(e){
                    var _this = $(this);
                    if(_this.hasClass('notExpand')) {
                        e.preventDefault();
                        //expand ul and change class to expand
                        _this.next('ul').slideDown(plugin.settings.sideNav.subOpenSpeed, plugin.settings.sideNav.animationEasing);
                        _this.next('ul').addClass('show');
                        _this.addClass('expand').removeClass('notExpand');
                        if(plugin.settings.sideNav.showArrows) {
                            _this.find('.sideNav-arrow').transition({rotate: '-180deg'});
                        }
                    } else if (_this.hasClass('expand')) {
                        e.preventDefault();
                        //collapse ul and change class to notExpand
                        _this.next('ul').removeClass('show');
                        _this.next('ul').slideUp(plugin.settings.sideNav.subCloseSpeed, plugin.settings.sideNav.animationEasing);
                        _this.addClass('notExpand').removeClass('expand');
                        if(plugin.settings.sideNav.showArrows) {
                            _this.find('.sideNav-arrow').transition({rotate: '0deg'});
                        }
                    }
                });
            }
        }

        //set current nav element
        plugin.setCurrentNav = function () {
            var domain = document.domain;
            var navig = $('#sideNav');
            var navLinks = navig.find('a');
            if(domain === '') {
                //domain not found
                var pageUrl = window.location.pathname.split( '/' );
                var winLoc = pageUrl.pop(); // get last item
                this.setCurrentClass(navLinks, winLoc);

            } else {
                if(plugin.settings.sideNav.absoluteUrl) {
                    //absolute url is enabled
                    var newDomain = 'http://' + domain + window.location.pathname;
                    setCurrentClass(navLinks, newDomain);

                } else {
                    //absolute url is disabled
                    var afterDomain = window.location.pathname.split( '/' );
                    var afterDomain = afterDomain.pop();
                    if(plugin.settings.sideNav.subDir != ''){
                        var afterDomain = window.location.pathname + plugin.settings.sideNav.subDir;
                    }
                    this.setCurrentClass(navLinks, afterDomain);
                }
            }
        }

        plugin.setCurrentClass = function (mainNavLinkAll, url) {
            mainNavLinkAll.each(function(index) {
                //convert href to array and get last element
                var href= $(this).attr('href');
                if(href === url) {
                    //set new current class
                    $(this).addClass('active');

                    ulElem = $(this).closest('ul');
                    if(ulElem.hasClass('sub')) {
                        //its a part of sub menu need to expand this menu
                        //aElem = ulElem.prev('a.hasUl').addClass('drop');
                        ulElem.addClass('show').css('display', 'block');
                        var _this = $(this).closest('li.hasSub').children('a.notExpand');
                        _this.removeClass('notExpand').addClass('expand active-state');
                        //_this.closest('li.hasSub').addClass('current');

                        if(plugin.settings.sideNav.showArrows) {
                            _this.find('.sideNav-arrow').transition({rotate: '-180deg'}, 0);
                        }
                    }
                } else {
                    if (url == '') {
                        url = 'index.html';
                    }
                    if (href === url) {
                        $(this).addClass('active');
                    }
                }

            });
        }

        //tile functions
        plugin.tile = function () {
            //cahce all tiles
            var tiles = $('.tile');

            //count numbers
            if(plugin.settings.tile.countNumbers) {
                var numbers = tiles.find('.tile-content>.number').not('.notCount');
                numbers.addClass('countTo');
                //get number
                numbers.each(function(index) {
                    //add data driven options
                    $(this).attr('data-from', 0);
                    $(this).attr('data-to', $(this).html());
                    //console.log($(this).html());
                });
                //activate plugin
                $('.countTo').countTo({
                    speed: 1000,
                    refreshInterval: 50
                });
            }

            tiles.hover(
                function () {
                    //in
                    tileNumber = $(this).find('.countTo');
                    //activate plugin
                    tileNumber.countTo({
                        speed: 200,
                        refreshInterval: 50
                    });
                },
                function () {
                    //out
                }
            );
        }

        //panels 
        plugin.panels = function () {
            //cache all panels
            var panels = $('.panel');

            panels.each(function( index ) {
                self = $(this);
                panelHeading = self.find('.panel-heading');
                //add id depend of first positon
                self.attr('id', 'spr_' + index);
                //inject all controls per class
                if(self.hasClass('toggle') || self.hasClass('panelClose') || self.hasClass('panelRefresh')) {
                    if(!panelHeading.find('.panel-controls').length) {
                        panelHeading.append('<div class="panel-controls">');
                        panelControls = panelHeading.find('.panel-controls');
                    } else {
                        panelControls = panelHeading.find('.panel-controls');
                    }
                }

                //panelMove
                if(self.hasClass('panelMove') && !panelControls.find('a.panel-move').length) {
                    panelControls.append('<a href="#" class="panel-move"><i class="'+ plugin.settings.panels.moveIcon+'"></i></a>');
                }

                //refresh
                if(self.hasClass('panelRefresh') && !panelControls.find('a.panel-refresh').length) {
                    panelControls.append('<a href="#" class="panel-refresh"><i class="'+ plugin.settings.panels.refreshIcon+'"></i></a>');
                }
                //Toggle
                if(self.hasClass('toggle') && !panelControls.find('a.toggle').length) {
                    if (self.hasClass('panel-closed')) {
                        panelControls.append('<a href="#" class="toggle panel-maximize"><i class="'+ plugin.settings.panels.collapseIcon+'"></i></a>');
                        self.find('.panel-body').slideToggle(0);
                        self.find('.panel-footer').slideToggle(0);
                        self.find('.panel-heading').toggleClass('min');
                    } else {
                        panelControls.append('<a href="#" class="toggle panel-minimize"><i class="'+ plugin.settings.panels.toggleIcon+'"></i></a>');
                    }
                }
                //close
                if(self.hasClass('panelClose') && !panelControls.find('a.panel-close').length) {
                    panelControls.append('<a href="#" class="panel-close"><i class="'+ plugin.settings.panels.closeIcon+'"></i></a>');
                }

                //show controls on this panel every time.
                if (self.hasClass('showControls')) {
                    self.find('.panel-controls').addClass('panel-controls-show');
                } else if (plugin.settings.panels.showControlsOnHover) {
                    self.find('.panel-controls').addClass('panel-controls-hide');
                }

            });

            panelControls = panels.find('.panel-controls');
            panelControlsLink = panelControls.find('a');


            if (plugin.settings.panels.showControlsOnHover) {
                //hover on panel
                panels.hover(
                    function () {
                        //in
                        if ($(this).find('.panel-controls').hasClass('panel-controls-hide')) {
                            $(this).find('.panel-controls').fadeIn(300);
                        }
                    },
                    function () {
                        //out
                        if ($(this).find('.panel-controls').hasClass('panel-controls-hide')) {
                            $(this).find('.panel-controls').fadeOut(300);
                        }
                    }
                );
            }

            //handle clicks
            panelControlsLink.click(function(e) {
                e.preventDefault();
                self = $(this);
                thisIcon = self.find('i');
                thisPanel = self.closest('.panel');
                thisPanelBody = thisPanel.find('.panel-body');
                thisPanelFooter = thisPanel.find('.panel-footer');
                thisPanelHeading = thisPanel.find('.panel-heading');

                //close click
                if (self.hasClass('panel-close')) {
                    setTimeout(function() {thisPanel.remove();}, 500);
                }

                //minimize and maximize click
                if (self.hasClass('toggle')) {
                    //minimize panel
                    self.toggleClass('panel-minimize panel-maximize');
                    thisIcon.toggleClass(plugin.settings.panels.toggleIcon +' '+plugin.settings.panels.collapseIcon);
                    thisPanelBody.slideToggle(200);
                    thisPanelFooter.slideToggle(200);
                    thisPanelHeading.toggleClass('min');
                }

                //refresh
                if (self.hasClass('panel-refresh')) {
                    //display overlay
                    thisPanel.append('<div class="panel-refresh-overlay"></div>');
                    thisPanel.append('<div class="progress-loader"><i class="'+ plugin.settings.panels.overlayRefreshIcon +' icon-spin"></i></div>');
                    thisIcon.addClass('icon-spin');
                    setTimeout(function() {
                        thisIcon.removeClass('icon-spin');
                        thisPanel.find('.panel-refresh-overlay').remove();
                        thisPanel.find('.progress-loader').remove();
                    }, 3000);
                }

            });

        }

        //activate sortable widgets and other elements
        plugin.sortable = function () {
            //sort options
            if ($('.outlet').hasClass('notSortable')) {
                //skip sortable
            } else {
                $('.outlet div[class*="col-lg-"]').sortable({
                    connectWith: '.outlet div[class*="col-lg"]',
                    handle: 'a.panel-move',
                    placeholder: "panel-placeholder",
                    forcePlaceholderSize: true,
                    helper: 'original',
                    forceHelperSize: true,
                    cursor: "move",
                    opacity: 0.8,
                    tolerance: "pointer",
                });
            }
        }

        // bootstrap accordion
        plugin.bsAccordion = function () {
            ;(function ($, window, document, undefined) {
                var pluginName = "bsAccordion",
                    defaults = {
                        toggle: false
                    };
                function Plugin(element, options) {
                    this.element = element;
                    this.settings = $.extend({}, defaults, options);
                    this._defaults = defaults;
                    this._name = pluginName;
                    this.init();
                }
                Plugin.prototype = {
                    init: function () {
                        var $this = $(this.element),
                            $toggle = this.settings.toggle;
                        $this.find('li.active').has('ul').children('ul').addClass('collapse in');
                        $this.find('li').not('.active').has('ul').children('ul').addClass('collapse');

                        $this.find('li').has('ul').children('a').on('click', function (e) {
                            e.preventDefault();

                            $(this).parent('li').toggleClass('active').children('ul').collapse('toggle');

                            if ($toggle) {
                                $(this).parent('li').siblings().removeClass('active').children('ul.in').collapse('hide');
                            }
                        });
                    }
                };
                $.fn[ pluginName ] = function (options) {
                    return this.each(function () {
                        if (!$.data(this, "plugin_" + pluginName)) {
                            $.data(this, "plugin_" + pluginName, new Plugin(this, options));
                        }
                    });
                };
            })(jQuery, window, document);
            $('.bsAccordion').bsAccordion();
        }

        // Checkboxes and radios
        plugin.checkAndRadios = function(themeColor) {
            chkClass = 'icheckbox_flat-'+themeColor;
            radClass = 'iradio_flat-'+themeColor;
            $('input').not('.noStyle').iCheck({
                checkboxClass: chkClass,
                radioClass: radClass
            });
        }

        plugin.chatWindow = function() {
            var chatUI = $('.chat-ui');
            var chatUserList = $('.chat-user-list');
            var chat_user = chatUI.find('a.chat-name');
            var chat_box = $('.chat-box');
            var close_chat = chat_box.find('a#close-user-chat');
            var chat_msgbox = chat_box.find('#sendMsg');
            var rsinner = $('#right-sidebar>.sidebar-inner');

            //activate scroll
            rsinner.slimScroll({
                position: "right",
                height: '100%',
                distance: '0',
                railVisible: false,
                size: plugin.settings.customScroll.size,
                color: plugin.settings.customScroll.color,
                railOpacity: plugin.settings.customScroll.opacity,
                railColor: plugin.settings.customScroll.railColor
            });

            chat_user.on("click", function(e){
                e.preventDefault();
                //show chat_box
                chat_box.addClass('chatbox-show');
                chatUserList.addClass('hide-it');
                rsinner.animate({ scrollTop: rsinner[0].scrollHeight }, 1000);
                //make textbox elastic
                chat_msgbox.autosize();
                //chat_msgbox.trigger('autosize.resize');
            });
            close_chat.on("click", function(e){
                e.preventDefault();
                //close chat_box
                chatUserList.removeClass('hide-it');
                chat_box.removeClass('chatbox-show');
            });

            //handle send msg
            chat_msgbox.on('keyup', function(e) {
                if (e.which == 13 && ! e.shiftKey) {
                    msg = $(this).val();
                    //append msg
                    appendMsg(msg);
                    //clear txt and resize text area to orginal state
                    $(this).val('').trigger('autosize.resize');
                    //scroll to bottom
                    rsinner.animate({ scrollTop: rsinner[0].scrollHeight }, 1000);
                }
            })

            function appendMsg (msg) {
                $('.chat-box .chat-messages').append('<li class="chat-me"><p class="avatar"><img src="https://s3.amazonaws.com/uifaces/faces/twitter/roybarberuk/48.jpg" alt="SuggeElson"></p><p class="chat-name">SuggeElson <span class="chat-time">Now</span></p><p class="chat-txt">'+ msg +'</p></li>');
            }
        }

        //responsive tables
        plugin.responsiveTables = function () {
            var tables = $('.table').not('.non-responsive');
            tables.each(function( index ) {
                $(this).wrap('<div class="table-responsive" />');
                if(plugin.settings.tables.customscroll) {
                    $("div.table-responsive").slimScrollHorizontal({
                        size: plugin.settings.customScroll.size,
                        color: plugin.settings.customScroll.color,
                        railOpacity: plugin.settings.customScroll.opacity,
                        width: '100%',
                        positon: 'bottom',
                        start: 'left',
                        railVisible: true,
                        distance: "3px",
                    });
                }
            });
        }

        //get colors
        plugin.getColors = function () {
            return plugin.settings.colors;
        }

        //back to top
        plugin.backToTop = function () {
            //GoUP 0.1.2 - Developed by Roger Vila (@_rogervila)
            (function(e){e.fn.goup=function(t){e.fn.goup.defaultOpts={appear:200,scrolltime:800,imgsrc:"http://goo.gl/VDOdQc",width:72,place:"bottom-right",fadein:500,fadeout:500,opacity:.5,marginX:2,marginY:2};var n=e.extend({},e.fn.goup.defaultOpts,t);return this.each(function(){var t=e(this);t.html("<a><img /></a>");var r=e("#goup a");var i=e("#goup a img");t.css({position:"fixed",display:"block",width:"'"+n.width+"px'","z-index":"9"});r.css("opacity",n.opacity);i.attr("src",n.imgsrc);i.width(n.width);i.hide();e(function(){e(window).scroll(function(){if(e(this).scrollTop()>n.appear)i.fadeIn(n.fadein);else i.fadeOut(n.fadeout)});e(r).hover(function(){e(this).css("opacity","1.0");e(this).css("cursor","pointer")},function(){e(this).css("opacity",n.opacity)});e(r).click(function(){e("body,html").animate({scrollTop:0},n.scrolltime);return false})});if(n.place==="top-right")t.css({top:n.marginY+"%",right:n.marginX+"%"});else if(n.place==="top-left")t.css({top:n.marginY+"%",left:n.marginX+"%"});else if(n.place==="bottom-right")t.css({bottom:n.marginY+"%",right:n.marginX+"%"});else if(n.place==="bottom-left")t.css({bottom:n.marginY+"%",left:n.marginX+"%"});else t.css({bottom:n.marginY+"%",right:n.marginX+"%"})})}})(jQuery);

            $('body').append('<div id="goup"></div>');
            $('#goup').goup({
                appear: 200,
                scrolltime: plugin.settings.backToTop.scrolltime,
                imgsrc: plugin.settings.backToTop.imgsrc,
                width: plugin.settings.backToTop.width,
                place: plugin.settings.backToTop.place,
                fadein: plugin.settings.backToTop.fadein,
                fadeout: plugin.settings.backToTop.fadeout,
                opacity: plugin.settings.backToTop.opacity,
                marginX: plugin.settings.backToTop.marginX,
                marginY: plugin.settings.backToTop.marginY,
            });
        }

        //center modal in page
        plugin.centerModal = function () {
            $('.modal').each(function(){
                if($(this).hasClass('in') == false){
                    $(this).show();
                };
                var contentHeight = $(window).height() - 60;
                var headerHeight = $(this).find('.modal-header').outerHeight() || 2;
                var footerHeight = $(this).find('.modal-footer').outerHeight() || 2;

                $(this).find('.modal-content').css({
                    'max-height': function () {
                        return contentHeight;
                    }
                });

                $(this).find('.modal-body').css({
                    'max-height': function () {
                        return contentHeight - (headerHeight + footerHeight);
                    }
                });

                $(this).find('.modal-dialog').addClass('modal-dialog-center').css({
                    'margin-top': function () {
                        return -($(this).outerHeight() / 2);
                    },
                    'margin-left': function () {
                        return -($(this).outerWidth() / 2);
                    }
                });
                if($(this).hasClass('in') == false){
                    $(this).hide();
                };
            });
        }

        //Update breadcrumbs
        plugin.breadCrumbs = function () {
            var breadcrumb = $('#crumb');
            var rightArrow = '<i class="en-arrow-right7"></i>';
            var homeIcon = '<i class="im-home"></i>';

            var navel = $('#sideNav>li a.active');
            var navsub = navel.closest('.nav.sub');
            //empty curmb
            breadcrumb.empty();
            breadcrumb.append('<li>'+homeIcon+'<a href="index.html">Home</a>'+rightArrow+'</li>');

            if (navsub.closest('li').hasClass('hasSub')) {
                //get previous
                navel1 = navsub.prev('a.expand');
                link = navel1.attr('href');
                icon1 = navel1.children('i').not('.sideNav-arrow').prop('outerHTML');
                text1 = navel1.children('.notification').remove().end().text().trim();

                breadcrumb.append('<li>'+icon1+'<a href="'+link+'">'+text1+'</a>'+rightArrow+'</li>');

                icon = navel.children('i').prop('outerHTML');
                text = navel.children('.indicator').remove().end().text();
                breadcrumb.append('<li>'+ icon +' '+ text +'</li>');

            } else {
                icon = navel.children('i').prop('outerHTML');
                text = navel.children('.indicator').remove().end().text();
                breadcrumb.append('<li>'+ icon +' '+ text +'</li>');
            }

        }

        plugin.launchFullScreen = function (el) {
            if ((document.fullScreenElement && document.fullScreenElement !== null) || (!document.mozFullScreen && !document.webkitIsFullScreen)) {
                $('body').addClass("full-screen");
                if (document.documentElement.requestFullScreen) {
                    document.documentElement.requestFullScreen();
                } else if (document.documentElement.mozRequestFullScreen) {
                    document.documentElement.mozRequestFullScreen();
                } else if (document.documentElement.webkitRequestFullScreen) {
                    document.documentElement.webkitRequestFullScreen(Element.ALLOW_KEYBOARD_INPUT);
                }
            } else {
                $('body').removeClass("full-screen");
                if (document.cancelFullScreen) {
                    document.cancelFullScreen();
                } else if (document.mozCancelFullScreen) {
                    document.mozCancelFullScreen();
                } else if (document.webkitCancelFullScreen) {
                    document.webkitCancelFullScreen();
                }
            }
        }

        plugin.toDoWidget = function () {
            var todos = $('.todo-widget');
            var items = todos.find('.todo-task-item');
            var chboxes = items.find('input[type="checkbox"]');
            var close = items.find('.close');

            $(chboxes).on('ifChecked', function(event){
                $(this).closest('.todo-task-item').addClass('task-done');
            });

            $(chboxes).on('ifUnchecked', function(event){
                $(this).closest('.todo-task-item').removeClass('task-done');
            });

            close.click(function() {
                $(this).closest('.todo-task-item').fadeOut('500');
            });
        }

        //storejs plugin
        plugin.storejs = function () {
            /* Copyright (c) 2010-2013 Marcus Westin */
            (function(e){function o(){try{return r in e&&e[r]}catch(t){return!1}}var t={},n=e.document,r="localStorage",i="script",s;t.disabled=!1,t.set=function(e,t){},t.get=function(e){},t.remove=function(e){},t.clear=function(){},t.transact=function(e,n,r){var i=t.get(e);r==null&&(r=n,n=null),typeof i=="undefined"&&(i=n||{}),r(i),t.set(e,i)},t.getAll=function(){},t.forEach=function(){},t.serialize=function(e){return JSON.stringify(e)},t.deserialize=function(e){if(typeof e!="string")return undefined;try{return JSON.parse(e)}catch(t){return e||undefined}};if(o())s=e[r],t.set=function(e,n){return n===undefined?t.remove(e):(s.setItem(e,t.serialize(n)),n)},t.get=function(e){return t.deserialize(s.getItem(e))},t.remove=function(e){s.removeItem(e)},t.clear=function(){s.clear()},t.getAll=function(){var e={};return t.forEach(function(t,n){e[t]=n}),e},t.forEach=function(e){for(var n=0;n<s.length;n++){var r=s.key(n);e(r,t.get(r))}};else if(n.documentElement.addBehavior){var u,a;try{a=new ActiveXObject("htmlfile"),a.open(),a.write("<"+i+">document.w=window</"+i+'><iframe src="/favicon.ico"></iframe>'),a.close(),u=a.w.frames[0].document,s=u.createElement("div")}catch(f){s=n.createElement("div"),u=n.body}function l(e){return function(){var n=Array.prototype.slice.call(arguments,0);n.unshift(s),u.appendChild(s),s.addBehavior("#default#userData"),s.load(r);var i=e.apply(t,n);return u.removeChild(s),i}}var c=new RegExp("[!\"#$%&'()*+,/\\\\:;<=>?@[\\]^`{|}~]","g");function h(e){return e.replace(/^d/,"___$&").replace(c,"___")}t.set=l(function(e,n,i){return n=h(n),i===undefined?t.remove(n):(e.setAttribute(n,t.serialize(i)),e.save(r),i)}),t.get=l(function(e,n){return n=h(n),t.deserialize(e.getAttribute(n))}),t.remove=l(function(e,t){t=h(t),e.removeAttribute(t),e.save(r)}),t.clear=l(function(e){var t=e.XMLDocument.documentElement.attributes;e.load(r);for(var n=0,i;i=t[n];n++)e.removeAttribute(i.name);e.save(r)}),t.getAll=function(e){var n={};return t.forEach(function(e,t){n[e]=t}),n},t.forEach=l(function(e,n){var r=e.XMLDocument.documentElement.attributes;for(var i=0,s;s=r[i];++i)n(s.name,t.deserialize(e.getAttribute(s.name)))})}try{var p="__storejs__";t.set(p,p),t.get(p)!=p&&(t.disabled=!0),t.remove(p)}catch(f){t.disabled=!0}t.enabled=!t.disabled,typeof module!="undefined"&&module.exports&&this.module!==module?module.exports=t:typeof define=="function"&&define.amd?define(t):e.store=t})(Function("return this")())
        }

        //transit plugin
        plugin.transit = function () {
            /*!* jQuery Transit - CSS3 transitions and transformations (c) 2011-2012 Rico Sta. Cruz <rico@ricostacruz.com>*/
            (function(k){k.transit={version:"0.9.9",propertyMap:{marginLeft:"margin",marginRight:"margin",marginBottom:"margin",marginTop:"margin",paddingLeft:"padding",paddingRight:"padding",paddingBottom:"padding",paddingTop:"padding"},enabled:true,useTransitionEnd:false};var d=document.createElement("div");var q={};function b(v){if(v in d.style){return v}var u=["Moz","Webkit","O","ms"];var r=v.charAt(0).toUpperCase()+v.substr(1);if(v in d.style){return v}for(var t=0;t<u.length;++t){var s=u[t]+r;if(s in d.style){return s}}}function e(){d.style[q.transform]="";d.style[q.transform]="rotateY(90deg)";return d.style[q.transform]!==""}var a=navigator.userAgent.toLowerCase().indexOf("chrome")>-1;q.transition=b("transition");q.transitionDelay=b("transitionDelay");q.transform=b("transform");q.transformOrigin=b("transformOrigin");q.transform3d=e();var i={transition:"transitionEnd",MozTransition:"transitionend",OTransition:"oTransitionEnd",WebkitTransition:"webkitTransitionEnd",msTransition:"MSTransitionEnd"};var f=q.transitionEnd=i[q.transition]||null;for(var p in q){if(q.hasOwnProperty(p)&&typeof k.support[p]==="undefined"){k.support[p]=q[p]}}d=null;k.cssEase={_default:"ease","in":"ease-in",out:"ease-out","in-out":"ease-in-out",snap:"cubic-bezier(0,1,.5,1)",easeOutCubic:"cubic-bezier(.215,.61,.355,1)",easeInOutCubic:"cubic-bezier(.645,.045,.355,1)",easeInCirc:"cubic-bezier(.6,.04,.98,.335)",easeOutCirc:"cubic-bezier(.075,.82,.165,1)",easeInOutCirc:"cubic-bezier(.785,.135,.15,.86)",easeInExpo:"cubic-bezier(.95,.05,.795,.035)",easeOutExpo:"cubic-bezier(.19,1,.22,1)",easeInOutExpo:"cubic-bezier(1,0,0,1)",easeInQuad:"cubic-bezier(.55,.085,.68,.53)",easeOutQuad:"cubic-bezier(.25,.46,.45,.94)",easeInOutQuad:"cubic-bezier(.455,.03,.515,.955)",easeInQuart:"cubic-bezier(.895,.03,.685,.22)",easeOutQuart:"cubic-bezier(.165,.84,.44,1)",easeInOutQuart:"cubic-bezier(.77,0,.175,1)",easeInQuint:"cubic-bezier(.755,.05,.855,.06)",easeOutQuint:"cubic-bezier(.23,1,.32,1)",easeInOutQuint:"cubic-bezier(.86,0,.07,1)",easeInSine:"cubic-bezier(.47,0,.745,.715)",easeOutSine:"cubic-bezier(.39,.575,.565,1)",easeInOutSine:"cubic-bezier(.445,.05,.55,.95)",easeInBack:"cubic-bezier(.6,-.28,.735,.045)",easeOutBack:"cubic-bezier(.175, .885,.32,1.275)",easeInOutBack:"cubic-bezier(.68,-.55,.265,1.55)"};k.cssHooks["transit:transform"]={get:function(r){return k(r).data("transform")||new j()},set:function(s,r){var t=r;if(!(t instanceof j)){t=new j(t)}if(q.transform==="WebkitTransform"&&!a){s.style[q.transform]=t.toString(true)}else{s.style[q.transform]=t.toString()}k(s).data("transform",t)}};k.cssHooks.transform={set:k.cssHooks["transit:transform"].set};if(k.fn.jquery<"1.8"){k.cssHooks.transformOrigin={get:function(r){return r.style[q.transformOrigin]},set:function(r,s){r.style[q.transformOrigin]=s}};k.cssHooks.transition={get:function(r){return r.style[q.transition]},set:function(r,s){r.style[q.transition]=s}}}n("scale");n("translate");n("rotate");n("rotateX");n("rotateY");n("rotate3d");n("perspective");n("skewX");n("skewY");n("x",true);n("y",true);function j(r){if(typeof r==="string"){this.parse(r)}return this}j.prototype={setFromString:function(t,s){var r=(typeof s==="string")?s.split(","):(s.constructor===Array)?s:[s];r.unshift(t);j.prototype.set.apply(this,r)},set:function(s){var r=Array.prototype.slice.apply(arguments,[1]);if(this.setter[s]){this.setter[s].apply(this,r)}else{this[s]=r.join(",")}},get:function(r){if(this.getter[r]){return this.getter[r].apply(this)}else{return this[r]||0}},setter:{rotate:function(r){this.rotate=o(r,"deg")},rotateX:function(r){this.rotateX=o(r,"deg")},rotateY:function(r){this.rotateY=o(r,"deg")},scale:function(r,s){if(s===undefined){s=r}this.scale=r+","+s},skewX:function(r){this.skewX=o(r,"deg")},skewY:function(r){this.skewY=o(r,"deg")},perspective:function(r){this.perspective=o(r,"px")},x:function(r){this.set("translate",r,null)},y:function(r){this.set("translate",null,r)},translate:function(r,s){if(this._translateX===undefined){this._translateX=0}if(this._translateY===undefined){this._translateY=0}if(r!==null&&r!==undefined){this._translateX=o(r,"px")}if(s!==null&&s!==undefined){this._translateY=o(s,"px")}this.translate=this._translateX+","+this._translateY}},getter:{x:function(){return this._translateX||0},y:function(){return this._translateY||0},scale:function(){var r=(this.scale||"1,1").split(",");if(r[0]){r[0]=parseFloat(r[0])}if(r[1]){r[1]=parseFloat(r[1])}return(r[0]===r[1])?r[0]:r},rotate3d:function(){var t=(this.rotate3d||"0,0,0,0deg").split(",");for(var r=0;r<=3;++r){if(t[r]){t[r]=parseFloat(t[r])}}if(t[3]){t[3]=o(t[3],"deg")}return t}},parse:function(s){var r=this;s.replace(/([a-zA-Z0-9]+)\((.*?)\)/g,function(t,v,u){r.setFromString(v,u)})},toString:function(t){var s=[];for(var r in this){if(this.hasOwnProperty(r)){if((!q.transform3d)&&((r==="rotateX")||(r==="rotateY")||(r==="perspective")||(r==="transformOrigin"))){continue}if(r[0]!=="_"){if(t&&(r==="scale")){s.push(r+"3d("+this[r]+",1)")}else{if(t&&(r==="translate")){s.push(r+"3d("+this[r]+",0)")}else{s.push(r+"("+this[r]+")")}}}}}return s.join(" ")}};function m(s,r,t){if(r===true){s.queue(t)}else{if(r){s.queue(r,t)}else{t()}}}function h(s){var r=[];k.each(s,function(t){t=k.camelCase(t);t=k.transit.propertyMap[t]||k.cssProps[t]||t;t=c(t);if(k.inArray(t,r)===-1){r.push(t)}});return r}function g(s,v,x,r){var t=h(s);if(k.cssEase[x]){x=k.cssEase[x]}var w=""+l(v)+" "+x;if(parseInt(r,10)>0){w+=" "+l(r)}var u=[];k.each(t,function(z,y){u.push(y+" "+w)});return u.join(", ")}k.fn.transition=k.fn.transit=function(z,s,y,C){var D=this;var u=0;var w=true;if(typeof s==="function"){C=s;s=undefined}if(typeof y==="function"){C=y;y=undefined}if(typeof z.easing!=="undefined"){y=z.easing;delete z.easing}if(typeof z.duration!=="undefined"){s=z.duration;delete z.duration}if(typeof z.complete!=="undefined"){C=z.complete;delete z.complete}if(typeof z.queue!=="undefined"){w=z.queue;delete z.queue}if(typeof z.delay!=="undefined"){u=z.delay;delete z.delay}if(typeof s==="undefined"){s=k.fx.speeds._default}if(typeof y==="undefined"){y=k.cssEase._default}s=l(s);var E=g(z,s,y,u);var B=k.transit.enabled&&q.transition;var t=B?(parseInt(s,10)+parseInt(u,10)):0;if(t===0){var A=function(F){D.css(z);if(C){C.apply(D)}if(F){F()}};m(D,w,A);return D}var x={};var r=function(H){var G=false;var F=function(){if(G){D.unbind(f,F)}if(t>0){D.each(function(){this.style[q.transition]=(x[this]||null)})}if(typeof C==="function"){C.apply(D)}if(typeof H==="function"){H()}};if((t>0)&&(f)&&(k.transit.useTransitionEnd)){G=true;D.bind(f,F)}else{window.setTimeout(F,t)}D.each(function(){if(t>0){this.style[q.transition]=E}k(this).css(z)})};var v=function(F){this.offsetWidth;r(F)};m(D,w,v);return this};function n(s,r){if(!r){k.cssNumber[s]=true}k.transit.propertyMap[s]=q.transform;k.cssHooks[s]={get:function(v){var u=k(v).css("transit:transform");return u.get(s)},set:function(v,w){var u=k(v).css("transit:transform");u.setFromString(s,w);k(v).css({"transit:transform":u})}}}function c(r){return r.replace(/([A-Z])/g,function(s){return"-"+s.toLowerCase()})}function o(s,r){if((typeof s==="string")&&(!s.match(/^[\-0-9\.]+$/))){return s}else{return""+s+r}}function l(s){var r=s;if(k.fx.speeds[r]){r=k.fx.speeds[r]}return o(r,"ms")}k.transit.getTransitionValue=g})(jQuery);
        }

        //mousewheel plugin
        plugin.mouseWheel = function() {
            (function($){var types=["DOMMouseScroll","mousewheel"];if($.event.fixHooks)for(var i=types.length;i;)$.event.fixHooks[types[--i]]=$.event.mouseHooks;$.event.special.mousewheel={setup:function(){if(this.addEventListener)for(var i=types.length;i;)this.addEventListener(types[--i],handler,false);else this.onmousewheel=handler},teardown:function(){if(this.removeEventListener)for(var i=types.length;i;)this.removeEventListener(types[--i],handler,false);else this.onmousewheel=null}};$.fn.extend({mousewheel:function(fn){return fn?
                this.bind("mousewheel",fn):this.trigger("mousewheel")},unmousewheel:function(fn){return this.unbind("mousewheel",fn)}});function handler(event){var orgEvent=event||window.event,args=[].slice.call(arguments,1),delta=0,returnValue=true,deltaX=0,deltaY=0;event=$.event.fix(orgEvent);event.type="mousewheel";if(orgEvent.wheelDelta)delta=orgEvent.wheelDelta/120;if(orgEvent.detail)delta=-orgEvent.detail/3;deltaY=delta;if(orgEvent.axis!==undefined&&orgEvent.axis===orgEvent.HORIZONTAL_AXIS){deltaY=0;deltaX=
                -1*delta}if(orgEvent.wheelDeltaY!==undefined)deltaY=orgEvent.wheelDeltaY/120;if(orgEvent.wheelDeltaX!==undefined)deltaX=-1*orgEvent.wheelDeltaX/120;args.unshift(event,delta,deltaX,deltaY);return($.event.dispatch||$.event.handle).apply(this,args)}})(jQuery);

        }

        //hover direction plugin
        plugin.hoverDirection = function () {
            /*! jQuery Hover Direction - v0.1.0 - 2014-02-13
             * https://github.com/ptouch718/jquery-hoverdirection
             * Copyright (c) 2014 Powell May; Licensed MIT */
            !function(a){function b(a){switch(a){case 0:return"top";case 1:return"right";case 2:return"bottom";case 3:return"left"}}function c(c){var d=a(this),e=d.height(),f=d.width(),g=(c.pageX-d.offset().left-f/2)*(f>e?e/f:1),h=(c.pageY-d.offset().top-e/2)*(e>f?f/e:1),i=Math.round((Math.atan2(h,g)*(180/Math.PI)+180)/90+3)%4,k=j.cssPrefix,l="mouseleave"===c.type?"leave":"enter",m=b(i);return k+"-"+l+"-"+m}function d(b){var d=c.apply(this,[b]);a(this).addClass(d)}function e(){a(this).removeClass(function(a,b){return(b.match(g)||[]).join(" ")})}function f(a){e.apply(this),d.apply(this,[a])}var g,h="hoverDirection",i={cssPrefix:"hover"},j={},k={init:function(b){return j=a.extend(i,b),g=new RegExp("\\"+j.cssPrefix+"\\S+","g"),this.each(function(){a(this).on("mouseenter mouseleave",f)})},removeClass:function(){return e.apply(this),this},destroy:function(){return e.apply(this),this.each(function(){a(this).off("mouseenter mouseleave",f)})}};a.fn[h]=function(b){return k[b]?k[b].apply(this,Array.prototype.slice.call(arguments,1)):"object"!=typeof b&&b?void a.error("Method "+b+" does not exist on jQuery."+h):k.init.apply(this)}}(jQuery,window,document);
        }

        //respondjs plugin
        plugin.respondjs = function () {

            // call jRespond and add breakpoints
            var jRes = jRespond([
                {
                    label: 'phone',
                    enter: 0,
                    exit: 767
                },{
                    label: 'tablet',
                    enter: 768,
                    exit: 979
                },{
                    label: 'laptop',
                    enter: 980,
                    exit: 1366
                },{
                    label: 'large',
                    enter: 1367,
                    exit: 10000
                }
            ]);
            // register enter and exit functions for a single breakpoint
            jRes.addFunc({
                breakpoint: 'laptop',
                enter: function() {
                    plugin.showLeftSidebar();
                },
                exit: function() {

                }
            });
            jRes.addFunc({
                breakpoint: 'tablet',
                enter: function() {
                    plugin.hideLeftSidebar();
                    plugin.collapseEmailAppSidebar();
                },
                exit: function() {
                    plugin.showLeftSidebar();
                    plugin.expandEmailAppSidebar();
                }
            });
            jRes.addFunc({
                breakpoint: 'phone',
                enter: function() {
                    plugin.hideLeftSidebar();
                    plugin.dropdownMenuFix();
                    plugin.collapseEmailAppSidebar();
                    $('#email-content').addClass('email-content-offCanvas');
                },
                exit: function() {
                    plugin.showLeftSidebar();
                    $('#email-content').removeClass('email-content-offCanvas');
                }
            });

            return jRes;
        }

        //fix dropdown menu ot top navigation in small screens
        plugin.dropdownMenuFix = function () {
            $("#header ul.dropdown-menu").each(function(){
                $(this).removeClass('right');
                var parentWidth = $(this).parent().innerWidth();
                var menuWidth = $(this).innerWidth();
                var margin = (parentWidth / 2 ) - (menuWidth / 2);
                margin = margin + "px";
                $(this).css("margin-left", margin);
            });
        }

        //quick search pluign
        plugin.quickSearch = function () {
            //quick search on sideNav
            if ($('.top-search input').length) {
                $('.top-search input').val('').quicksearch('#sideNav li a', {
                    'onBefore': function () {
                        if($(this).val() != '') {
                            plugin.expandSideBarNav();
                        }
                    },
                    'onAfter': function () {
                        if($(this).val() == '') {
                            plugin.collapseSideBarNav();
                        }
                    },
                });
            }

            //quick search on chat users
            if ($('.chat-search input').length) {
                $('.chat-search input').val('').quicksearch('.chat-ui li');
            }

            //quick search on todo widget
            if ($('.todo-search input').length) {
                $('.todo-search input').val('').quicksearch('.todo-list .todo-task-item');
            }

            //quick search on recent-users widget
            if ($('.users-search input').length) {
                $('.users-search input').val('').quicksearch('.recent-users-widget .list-group-item');
            }

            //quick search on email app toolbar
            if ($('.email-toolbar-search input').length) {
                $('.email-toolbar-search input').val('').quicksearch('.email-list tr');
            }
        }

        //expand all nav ul element
        plugin.expandSideBarNav = function () {
            nav = $('#sideNav');
            nava = nav.find('a.notExpand');
            nava.next('ul').slideDown(plugin.settings.sideNav.subOpenSpeed, plugin.settings.sideNav.animationEasing);
            nava.next('ul').addClass('show');
            nava.addClass('expand').removeClass('notExpand');
            if(plugin.settings.sideNav.showArrows) {
                nava.find('.sideNav-arrow').transition({rotate: '-180deg'});
            }
        }

        //collapse all nav ul elements except current
        plugin.collapseSideBarNav = function () {
            nav = $('#sideNav');
            nava = nav.find('a.expand').not('a.active-state');
            nava.next('ul').slideUp(plugin.settings.sideNav.subOpenSpeed, plugin.settings.sideNav.animationEasing);
            nava.next('ul').removeClass('show');
            nava.addClass('notExpand').removeClass('expand');
            if(plugin.settings.sideNav.showArrows) {
                nava.find('.sideNav-arrow').transition({rotate: '0deg'});
            }
        }

        //email app 
        plugin.emailApp = function () {
            var eside = $('#email-sidebar');
            var econtent = $('#email-content');

            $("#email-toggle").click(function(){
                if ($(this).hasClass('pushed')) {
                    $(this).removeClass('pushed');
                    eside.removeClass('email-sidebar-hide');
                    eside.addClass('email-sidebar-show');
                    econtent.removeClass('email-content-expand');
                    econtent.addClass('email-content-contract');
                } else {
                    $(this).addClass('pushed');
                    eside.removeClass('email-sidebar-show');
                    eside.addClass('email-sidebar-hide');
                    econtent.removeClass('email-content-contract');
                    econtent.addClass('email-content-expand');
                }
            });
        }

        //collapse email sidbear
        plugin.collapseEmailAppSidebar = function () {
            var eside = $('#email-sidebar');
            var econtent = $('#email-content');
            eside.removeClass('email-sidebar-show');
            eside.addClass('email-sidebar-hide');
            econtent.removeClass('email-content-contract');
            econtent.addClass('email-content-expand');
            $("#email-toggle").addClass('pushed');
        }

        //expand email sidbear
        plugin.expandEmailAppSidebar = function () {
            var eside = $('#email-sidebar');
            var econtent = $('#email-content');
            eside.removeClass('email-sidebar-hide');
            eside.addClass('email-sidebar-show');
            econtent.removeClass('email-content-expand');
            econtent.addClass('email-content-contract');
            $("#email-toggle").removeClass('pushed');
        }

        //animation for dropdown menus
        plugin.dropdownMenuAnimations = function () {
            openEffect = 'animated ' + plugin.settings.dropdownMenu.openEffect;

            $('.dropdown').on('show.bs.dropdown', function () {
                $(this).find('.dropdown-menu').addClass(openEffect);
            })
        }

        //retina ready images
        plugin.retinaReady = function () {
            !function(){function a(){}function b(a){return f.retinaImageSuffix+a}function c(a,c){if(this.path=a||"","undefined"!=typeof c&&null!==c)this.at_2x_path=c,this.perform_check=!1;else{if(void 0!==document.createElement){var d=document.createElement("a");d.href=this.path,d.pathname=d.pathname.replace(g,b),this.at_2x_path=d.href}else{var e=this.path.split("?");e[0]=e[0].replace(g,b),this.at_2x_path=e.join("?")}this.perform_check=!0}}function d(a){this.el=a,this.path=new c(this.el.getAttribute("src"),this.el.getAttribute("data-at2x"));var b=this;this.path.check_2x_variant(function(a){a&&b.swap()})}var e="undefined"==typeof exports?window:exports,f={retinaImageSuffix:"@2x",check_mime_type:!0,force_original_dimensions:!0};e.Retina=a,a.configure=function(a){null===a&&(a={});for(var b in a)a.hasOwnProperty(b)&&(f[b]=a[b])},a.init=function(a){null===a&&(a=e);var b=a.onload||function(){};a.onload=function(){var a,c,e=document.getElementsByTagName("img"),f=[];for(a=0;a<e.length;a+=1)c=e[a],c.getAttributeNode("data-no-retina")||f.push(new d(c));b()}},a.isRetina=function(){var a="(-webkit-min-device-pixel-ratio: 1.5), (min--moz-device-pixel-ratio: 1.5), (-o-min-device-pixel-ratio: 3/2), (min-resolution: 1.5dppx)";return e.devicePixelRatio>1?!0:e.matchMedia&&e.matchMedia(a).matches?!0:!1};var g=/\.\w+$/;e.RetinaImagePath=c,c.confirmed_paths=[],c.prototype.is_external=function(){return!(!this.path.match(/^https?\:/i)||this.path.match("//"+document.domain))},c.prototype.check_2x_variant=function(a){var b,d=this;return this.is_external()?a(!1):this.perform_check||"undefined"==typeof this.at_2x_path||null===this.at_2x_path?this.at_2x_path in c.confirmed_paths?a(!0):(b=new XMLHttpRequest,b.open("HEAD",this.at_2x_path),b.onreadystatechange=function(){if(4!==b.readyState)return a(!1);if(b.status>=200&&b.status<=399){if(f.check_mime_type){var e=b.getResponseHeader("Content-Type");if(null===e||!e.match(/^image/i))return a(!1)}return c.confirmed_paths.push(d.at_2x_path),a(!0)}return a(!1)},b.send(),void 0):a(!0)},e.RetinaImage=d,d.prototype.swap=function(a){function b(){c.el.complete?(f.force_original_dimensions&&(c.el.setAttribute("width",c.el.offsetWidth),c.el.setAttribute("height",c.el.offsetHeight)),c.el.setAttribute("src",a)):setTimeout(b,5)}"undefined"==typeof a&&(a=this.path.at_2x_path);var c=this;b()},a.isRetina()&&a.init(e)}();
        }

        // private methods
        var foo_private_method = function() {
            // code goes here
        }

        // fire up the plugin!
        // call the "constructor" method
        plugin.init();

    }

    // add the plugin to the jQuery.fn object
    $.fn.sprFlat = function(options) {

        // iterate through the DOM elements we are attaching the plugin to
        return this.each(function() {

            // if plugin has not already been attached to the element
            if (undefined == $(this).data('sprFlat')) {

                // create a new instance of the plugin
                // pass the DOM element and the user-provided options as arguments
                var plugin = new $.sprFlat(this, options);

                // store a reference to the plugin object
                // element.data('sprFlat').publicMethod(arg1, arg2, ... argn) or
                // element.data('sprFlat').settings.propertyName
                $(this).data('sprFlat', plugin);

            }

        });

    }

})(jQuery);

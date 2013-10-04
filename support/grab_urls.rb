#!/usr/bin/env ruby

require "nokogiri"
require "yaml"

original_pos = DATA.pos
grab_data = DATA.read.strip.size == 0
DATA.seek(original_pos)
if grab_data
  require "capybara"
  require "capybara-webkit"

  Capybara.configure do |c|
    c.default_driver = :webkit
    c.current_driver = :webkit
    c.javascript_driver = :webkit
  end

  include Capybara::DSL

  visit "http://www.modern.ie/en-us/virtualization-tools"

  find("a.expandable-title", text: "Get free VMs").click

  %w{
    $("a.expandable-title[href=\"#downloads\"]").click()
    $("#os-select").val("mac").change()
    $("#platform-select").val("virtbox").change()
  }.each do |js|
    page.execute_script(js)
  end

  File.open(__FILE__, "a+") do |f|
    f.seek(DATA.pos)
    f.puts page.body
  end
end

doc = Nokogiri::HTML(DATA.read)
os_lists = doc.search("#platform-links li")

data = os_lists.inject(Hash.new) do |d, li|
  next(d) unless li.search("div.platform-partial-cell").first

  name = li.search("p.cta").first.text
  urls = li.search(".platform-link-partial").map {|x| x[:href] }

  name.sub!("RP", "Preview")
  name.sub!(" Preview", "preview")
  name.sub!(/Win7.+/, "Win7")
  name.sub!(/ [-–] /, "_")

  d[name] = urls
  d
end

print data.to_yaml

__END__
<!DOCTYPE html><!--[if lt IE 7]><html class="no-js lt-ie9 lt-ie8 lt-ie7" lang="en-us"><![endif]--><!--[if IE 7]><html class="no-js lt-ie10 lt-ie9 lt-ie8" lang="en-us"> <![endif]--><!--[if IE 8]><html class="no-js lt-ie10 lt-ie9" lang="en-us"><![endif]--><!--[if IE 9]><html class="no-js lt-ie10" lang="en-us"><![endif]--><!--[if gt IE 9]><!--><html class=" js touch history backgroundsize cssanimations csstransforms no-csstransforms3d csstransitions fontface generatedcontent mqs no-pointers" lang="en-us" style=""><!--<![endif]--><head><script async="" src="http://view.atdmt.com/jaction/SMG_MRTINX_ModernIE_GetTheVMs?_=1380269779940"></script>
    <meta http-equiv="X-UA-Compatible" content="IE=Edge">
    <meta charset="utf-8">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
    <meta name="search.content.shortId" content="br229512">
    <meta name="search.content.locale" content="en-us">
    <meta http-equiv="content-language" content="en-us">
    <link rel="canonical" href="">
    <meta name="NormalizedUrl" content="http://www.modern.ie">
    <meta name="Title" content="Cross-browser testing simplified | Testing made easier in Internet Explorer | modern.IE">
    <meta name="description" content="Testing for Internet Explorer just got a little easier.">
    <meta name="PTSearchTitle" content="Cross-browser testing simplified | Testing made easier in Internet Explorer | modern.IE">
    <meta name="win_center" content="windows_apps">
    <meta name="win_section" content="home">
    <meta name="Search.center" content="windows_apps">
    <meta name="Search.MSCategory" content="br229511">
    <meta name="Search.MSCategory" content="br229513">
    <meta name="Search.TocNodeId" content="br229513">

    <title>Cross-browser testing simplified | Testing made easier in Internet Explorer | modern.IE</title>
    <meta name="viewport" content="width=device-width">
        
    <meta property="og:title" content="Testing made easier in Internet Explorer | modern.IE">
    <meta property="og:description" content="Less time testing IE. More time building what matters.">
    <meta property="og:image" content="http://www.modern.ie/cdn/img/facebook_200x200.png">
    <meta name="msapplication-starturl" content="http://www.modern.ie">
    <meta name="msapplication-navbutton-color" content="#00bcf4">
    <meta name="msapplication-tooltip" content="Cross-browser testing simplified | Testing made easier in Internet Explorer | modern.IE">

    <meta name="application-name" content="modern.IE">
    <meta name="msapplication-TileColor" content="#00bcf4">
    <meta name="msapplication-TileImage" content="/cdn/img/win_tile_144x144.png">
    

    <link rel="shortcut icon" href="/favicon.ico">

    
<link href="/cassette.axd/stylesheet/d29347d8469e71124615b4e1a25eb7aa4c88870e/cdn/css/global" type="text/css" rel="stylesheet">

    
<link href="/cassette.axd/stylesheet/45684b8cd84175de5e5e36242347ce81847d72f1/cdn/css/versions/v2/global/main.less" type="text/css" rel="stylesheet">

    


    


    
<script src="//www.google-analytics.com/ga.js"></script><script id="twitter-wjs" src="//platform.twitter.com/widgets.js"></script><script id="facebook-jssdk" src="//connect.facebook.net/en_US/all.js#xfbml=1"></script><script src="/cassette.axd/script/39e31896a7c38fdda93d81b7103d7d53cb3afda3/cdn/js/head" type="text/javascript"></script>


    

<script type="text/javascript">var NREUMQ=NREUMQ||[];NREUMQ.push(["mark","firstbyte",new Date().getTime()]);</script><style type="text/css">.fb_hidden{position:absolute;top:-10000px;z-index:10001}
.fb_invisible{display:none}
.fb_reset{background:none;border:0;border-spacing:0;color:#000;cursor:auto;direction:ltr;font-family:"lucida grande", tahoma, verdana, arial, sans-serif;font-size:11px;font-style:normal;font-variant:normal;font-weight:normal;letter-spacing:normal;line-height:1;margin:0;overflow:visible;padding:0;text-align:left;text-decoration:none;text-indent:0;text-shadow:none;text-transform:none;visibility:visible;white-space:normal;word-spacing:normal}
.fb_reset > div{overflow:hidden}
.fb_link img{border:none}
.fb_dialog{background:rgba(82, 82, 82, .7);position:absolute;top:-10000px;z-index:10001}
.fb_dialog_advanced{padding:10px;-moz-border-radius:8px;-webkit-border-radius:8px;border-radius:8px}
.fb_dialog_content{background:#fff;color:#333}
.fb_dialog_close_icon{background:url(http://static.ak.fbcdn.net/rsrc.php/v2/yq/r/IE9JII6Z1Ys.png) no-repeat scroll 0 0 transparent;_background-image:url(http://static.ak.fbcdn.net/rsrc.php/v2/yL/r/s816eWC-2sl.gif);cursor:pointer;display:block;height:15px;position:absolute;right:18px;top:17px;width:15px;top:8px\9;right:7px\9}
.fb_dialog_mobile .fb_dialog_close_icon{top:5px;left:5px;right:auto}
.fb_dialog_padding{background-color:transparent;position:absolute;width:1px;z-index:-1}
.fb_dialog_close_icon:hover{background:url(http://static.ak.fbcdn.net/rsrc.php/v2/yq/r/IE9JII6Z1Ys.png) no-repeat scroll 0 -15px transparent;_background-image:url(http://static.ak.fbcdn.net/rsrc.php/v2/yL/r/s816eWC-2sl.gif)}
.fb_dialog_close_icon:active{background:url(http://static.ak.fbcdn.net/rsrc.php/v2/yq/r/IE9JII6Z1Ys.png) no-repeat scroll 0 -30px transparent;_background-image:url(http://static.ak.fbcdn.net/rsrc.php/v2/yL/r/s816eWC-2sl.gif)}
.fb_dialog_loader{background-color:#f2f2f2;border:1px solid #606060;font-size:24px;padding:20px}
.fb_dialog_top_left,
.fb_dialog_top_right,
.fb_dialog_bottom_left,
.fb_dialog_bottom_right{height:10px;width:10px;overflow:hidden;position:absolute}
.fb_dialog_top_left{background:url(http://static.ak.fbcdn.net/rsrc.php/v2/ye/r/8YeTNIlTZjm.png) no-repeat 0 0;left:-10px;top:-10px}
.fb_dialog_top_right{background:url(http://static.ak.fbcdn.net/rsrc.php/v2/ye/r/8YeTNIlTZjm.png) no-repeat 0 -10px;right:-10px;top:-10px}
.fb_dialog_bottom_left{background:url(http://static.ak.fbcdn.net/rsrc.php/v2/ye/r/8YeTNIlTZjm.png) no-repeat 0 -20px;bottom:-10px;left:-10px}
.fb_dialog_bottom_right{background:url(http://static.ak.fbcdn.net/rsrc.php/v2/ye/r/8YeTNIlTZjm.png) no-repeat 0 -30px;right:-10px;bottom:-10px}
.fb_dialog_vert_left,
.fb_dialog_vert_right,
.fb_dialog_horiz_top,
.fb_dialog_horiz_bottom{position:absolute;background:#525252;filter:alpha(opacity=70);opacity:.7}
.fb_dialog_vert_left,
.fb_dialog_vert_right{width:10px;height:100%}
.fb_dialog_vert_left{margin-left:-10px}
.fb_dialog_vert_right{right:0;margin-right:-10px}
.fb_dialog_horiz_top,
.fb_dialog_horiz_bottom{width:100%;height:10px}
.fb_dialog_horiz_top{margin-top:-10px}
.fb_dialog_horiz_bottom{bottom:0;margin-bottom:-10px}
.fb_dialog_iframe{line-height:0}
.fb_dialog_content .dialog_title{background:#6d84b4;border:1px solid #3b5998;color:#fff;font-size:14px;font-weight:bold;margin:0}
.fb_dialog_content .dialog_title > span{background:url(http://static.ak.fbcdn.net/rsrc.php/v2/yd/r/Cou7n-nqK52.gif)
no-repeat 5px 50%;float:left;padding:5px 0 7px 26px}
body.fb_hidden{-webkit-transform:none;height:100%;margin:0;left:-10000px;overflow:visible;position:absolute;top:-10000px;width:100%
}
.fb_dialog.fb_dialog_mobile.loading{background:url(http://static.ak.fbcdn.net/rsrc.php/v2/ya/r/3rhSv5V8j3o.gif)
white no-repeat 50% 50%;min-height:100%;min-width:100%;overflow:hidden;position:absolute;top:0;z-index:10001}
.fb_dialog.fb_dialog_mobile.loading.centered{max-height:590px;min-height:590px;max-width:500px;min-width:500px}
#fb-root #fb_dialog_ipad_overlay{background:rgba(0, 0, 0, .45);position:absolute;left:0;top:0;width:100%;min-height:100%;z-index:10000}
#fb-root #fb_dialog_ipad_overlay.hidden{display:none}
.fb_dialog.fb_dialog_mobile.loading iframe{visibility:hidden}
.fb_dialog_content .dialog_header{-webkit-box-shadow:white 0 1px 1px -1px inset;background:-webkit-gradient(linear, 0 0, 0 100%, from(#738ABA), to(#2C4987));border-bottom:1px solid;border-color:#1d4088;color:#fff;font:14px Helvetica, sans-serif;font-weight:bold;text-overflow:ellipsis;text-shadow:rgba(0, 30, 84, .296875) 0 -1px 0;vertical-align:middle;white-space:nowrap}
.fb_dialog_content .dialog_header table{-webkit-font-smoothing:subpixel-antialiased;height:43px;width:100%
}
.fb_dialog_content .dialog_header td.header_left{font-size:12px;padding-left:5px;vertical-align:middle;width:60px
}
.fb_dialog_content .dialog_header td.header_right{font-size:12px;padding-right:5px;vertical-align:middle;width:60px
}
.fb_dialog_content .touchable_button{background:-webkit-gradient(linear, 0 0, 0 100%, from(#4966A6),
color-stop(0.5, #355492), to(#2A4887));border:1px solid #29447e;-webkit-background-clip:padding-box;-webkit-border-radius:3px;-webkit-box-shadow:rgba(0, 0, 0, .117188) 0 1px 1px inset,
rgba(255, 255, 255, .167969) 0 1px 0;display:inline-block;margin-top:3px;max-width:85px;line-height:18px;padding:4px 12px;position:relative}
.fb_dialog_content .dialog_header .touchable_button input{border:none;background:none;color:#fff;font:12px Helvetica, sans-serif;font-weight:bold;margin:2px -12px;padding:2px 6px 3px 6px;text-shadow:rgba(0, 30, 84, .296875) 0 -1px 0}
.fb_dialog_content .dialog_header .header_center{color:#fff;font-size:16px;font-weight:bold;line-height:18px;text-align:center;vertical-align:middle}
.fb_dialog_content .dialog_content{background:url(http://static.ak.fbcdn.net/rsrc.php/v2/y9/r/jKEcVPZFk-2.gif) no-repeat 50% 50%;border:1px solid #555;border-bottom:0;border-top:0;height:150px}
.fb_dialog_content .dialog_footer{background:#f2f2f2;border:1px solid #555;border-top-color:#ccc;height:40px}
#fb_dialog_loader_close{float:left}
.fb_dialog.fb_dialog_mobile .fb_dialog_close_button{text-shadow:rgba(0, 30, 84, .296875) 0 -1px 0}
.fb_dialog.fb_dialog_mobile .fb_dialog_close_icon{visibility:hidden}
.fb_iframe_widget{display:inline-block;position:relative}
.fb_iframe_widget span{display:inline-block;position:relative;text-align:justify}
.fb_iframe_widget iframe{position:absolute}
.fb_iframe_widget_lift{z-index:1}
.fb_hide_iframes iframe{position:relative;left:-10000px}
.fb_iframe_widget_loader{position:relative;display:inline-block}
.fb_iframe_widget_fluid{display:inline}
.fb_iframe_widget_fluid span{width:100%}
.fb_iframe_widget_loader iframe{min-height:32px;z-index:2;zoom:1}
.fb_iframe_widget_loader .FB_Loader{background:url(http://static.ak.fbcdn.net/rsrc.php/v2/y9/r/jKEcVPZFk-2.gif) no-repeat;height:32px;width:32px;margin-left:-16px;position:absolute;left:50%;z-index:4}
.fb_connect_bar_container div,
.fb_connect_bar_container span,
.fb_connect_bar_container a,
.fb_connect_bar_container img,
.fb_connect_bar_container strong{background:none;border-spacing:0;border:0;direction:ltr;font-style:normal;font-variant:normal;letter-spacing:normal;line-height:1;margin:0;overflow:visible;padding:0;text-align:left;text-decoration:none;text-indent:0;text-shadow:none;text-transform:none;visibility:visible;white-space:normal;word-spacing:normal;vertical-align:baseline}
.fb_connect_bar_container{position:fixed;left:0 !important;right:0 !important;height:42px !important;padding:0 25px !important;margin:0 !important;vertical-align:middle !important;border-bottom:1px solid #333 !important;background:#3b5998 !important;z-index:99999999 !important;overflow:hidden !important}
.fb_connect_bar_container_ie6{position:absolute;top:expression(document.compatMode=="CSS1Compat"? document.documentElement.scrollTop+"px":body.scrollTop+"px")}
.fb_connect_bar{position:relative;margin:auto;height:100%;width:100%;padding:6px 0 0 0 !important;background:none;color:#fff !important;font-family:"lucida grande", tahoma, verdana, arial, sans-serif !important;font-size:13px !important;font-style:normal !important;font-variant:normal !important;font-weight:normal !important;letter-spacing:normal !important;line-height:1 !important;text-decoration:none !important;text-indent:0 !important;text-shadow:none !important;text-transform:none !important;white-space:normal !important;word-spacing:normal !important}
.fb_connect_bar a:hover{color:#fff}
.fb_connect_bar .fb_profile img{height:30px;width:30px;vertical-align:middle;margin:0 6px 5px 0}
.fb_connect_bar div a,
.fb_connect_bar span,
.fb_connect_bar span a{color:#bac6da;font-size:11px;text-decoration:none}
.fb_connect_bar .fb_buttons{float:right;margin-top:7px}
.fb_edge_widget_with_comment{position:relative;*z-index:1000}
.fb_edge_widget_with_comment span.fb_edge_comment_widget{position:absolute}
.fb_edge_widget_with_comment span.fb_send_button_form_widget{z-index:1}
.fb_edge_widget_with_comment span.fb_send_button_form_widget .FB_Loader{left:0;top:1px;margin-top:6px;margin-left:0;background-position:50% 50%;background-color:#fff;height:150px;width:394px;border:1px #666 solid;border-bottom:2px solid #283e6c;z-index:1}
.fb_edge_widget_with_comment span.fb_send_button_form_widget.dark .FB_Loader{background-color:#000;border-bottom:2px solid #ccc}
.fb_edge_widget_with_comment span.fb_send_button_form_widget.siderender
.FB_Loader{margin-top:0}
.fbpluginrecommendationsbarleft,
.fbpluginrecommendationsbarright{position:fixed !important;bottom:0;z-index:999}
.fbpluginrecommendationsbarleft{left:10px}
.fbpluginrecommendationsbarright{right:10px}</style></head>
    <body class="en-us" data-twttr-rendered="true">
        <div id="fb-root" class=" fb_reset"><div style="position: absolute; top: -10000px; height: 0px; width: 0px; "><div><iframe name="fb_xdm_frame_http" frameborder="0" allowtransparency="true" scrolling="no" id="fb_xdm_frame_http" aria-hidden="true" title="Facebook Cross Domain Communication Frame" tab-index="-1" style="border-top-style: none; border-right-style: none; border-bottom-style: none; border-left-style: none; border-width: initial; border-color: initial; " src="http://static.ak.facebook.com/connect/xd_arbiter.php?version=27#channel=f32b426f94&amp;channel_path=%2Fen-us%2Fvirtualization-tools%3Ffb_xd_fragment%23xd_sig%3Df2f55d99dc%26&amp;origin=http%3A%2F%2Fwww.modern.ie"></iframe><iframe name="fb_xdm_frame_https" frameborder="0" allowtransparency="true" scrolling="no" id="fb_xdm_frame_https" aria-hidden="true" title="Facebook Cross Domain Communication Frame" tab-index="-1" style="border-top-style: none; border-right-style: none; border-bottom-style: none; border-left-style: none; border-width: initial; border-color: initial; " src="https://s-static.ak.facebook.com/connect/xd_arbiter.php?version=27#channel=f32b426f94&amp;channel_path=%2Fen-us%2Fvirtualization-tools%3Ffb_xd_fragment%23xd_sig%3Df2f55d99dc%26&amp;origin=http%3A%2F%2Fwww.modern.ie"></iframe></div></div><div style="position: absolute; top: -10000px; height: 0px; width: 0px; "><div></div></div></div>
        <script>(function(d, s, id) {
            var js, fjs = d.getElementsByTagName(s)[0];
            if (d.getElementById(id)) return;
            js = d.createElement(s); js.id = id;
            js.src = "//connect.facebook.net/en_US/all.js#xfbml=1";
            fjs.parentNode.insertBefore(js, fjs);
        }(document, 'script', 'facebook-jssdk'));</script>
        <!-- Begin Windows Dev Center Header -->
        <header class="ux-header">
            <div class="grid-container">
                <div class="search">
                    <form id="HeaderSearchForm" method="get" target="_blank" action="http://social.msdn.microsoft.com/search/en-US/ie/">
                        <input name="query" id="HeaderSearchTextBox" class="textboxsearch" type="text" maxlength="100" placeholder="Search IE DevCenter" title="Search IE DevCenter">
                        <input name="Refinement" type="hidden" value="61,117">
                        <input id="HeaderSearchButton" value="" class="header-search-button" type="submit" title="Search IE DevCenter">   
                    </form>
                </div>
                <div class="siteLogo">
                    <a href="/" title="modern.IE" class="target-self" target="_self">
                        <img src="/cdn/img/ie_logo.png" class="sitelogoImage" alt="Internet Explorer">
                        <span>modern.IE</span>
                    </a>
                </div>
            </div><!-- .grid-container -->
        </header>
        <!-- End Windows Dev Center Header -->
        <!-- Begin Nav -->
        <nav id="windowstore-navigation" role="navigation" class="menu">
            <div class="grid-container">
                <div class="site-header-togglers clearfix">
                  <a href="#windows-store-navigation" id="toggle-menu" class="toggle toggle-menu" title="Toggle Navigation">
                    <span class="icon-menu" aria-role="hidden"></span>
                    <span class="screen-reader-text">Menu</span>
                  </a>
                </div><!-- site-header-togglers -->
            </div><!-- grid-container -->
            <div class="grid-container">
                <ul class="menu-bar" role="menubar">
                  <li role="menuitem" class="menu-item"> <a href="/" title="modern.IE" class="home">Home</a></li>
                  <li role="menuitem" class="menu-item"><a href="/report" title="Scan a webpage">Scan a webpage</a></li>
                  <li role="menuitem" class="menu-item active"><a href="/virtualization-tools" title="Test across browsers">Test across browsers</a></li>
                  <li role="menuitem" class="menu-item"><a href="/cross-browser-best-practices" title="Code with standards">Code with standards</a></li>
                  <li role="menuitem" class="menu-item"><a href="http://ie.microsoft.com/testdrive/" title="Meet IE" target="_blank">Meet IE</a></li>
                  <li role="menuitem" class="menu-item"><a href="http://ie.microsoft.com/testdrive/Info/Downloads/Default.html" title="Download IE" target="_blank">Download IE</a></li>
                  <li role="menuitem" class="menu-item"><a href="http://www.twitter.com/iedevchat" title="Follow @IEDevChat" target="_blank">Follow @IEDevChat</a></li>
                  <li role="menuitem" class="menu-item"><a href="http://useragents.ie/" title="IE userAgents" target="_blank">IE userAgents</a></li>
                  <li role="menuitem" class="menu-item"><a href="/about" title="About">About</a></li>
                </ul>
            </div><!-- grid-container -->
        </nav><!-- End Nav -->
 
        


<!-- Headline -->
<div class="grid-container devtools-head">
    <div class="grid-row">

		<div class="grid-unit">

			<h1> Start testing your site with these virtual tools:</h1>

		</div>

	</div><!-- .grid-row -->
</div><!--  -->

<!-- BrowserStack expandable -->
<div id="devtools">
    <div id="browserstack" class="grid-container expandable">
        <div class="grid-row row-2">
            <div class="grid-unit">
                <h1>Test across browsers in a few clicks.</h1>                
            </div>
            <div class="grid-unit browserstack">
                <img src="/cdn/img/home/browserstack_logo.png" alt="Browserstack">
                <div class="steps">
                    <p>BrowserStack lets you instantly view your site across browsers, across platforms. <span>Try 3 months of it free on us.</span></p>
                        <form action="http://www.browserstack.com" class="offer-form">
                            <input type="text" id="url" name="url" value="" placeholder="http://yoursite.com" class="url-touch-zoom-disabled">
                            <button type="submit" href="http://browserstack.com" id="bwsrstk" class="cta check_site" value="Test free on BrowserStack">Test free on BrowserStack</button>
                            <input type="hidden" id="cbsid" name="cbsid" value="">
                            <label class="url-error-label">Please Enter a Valid URL</label>
                        </form>
                </div>
            </div>
        </div>
        <a href="" title="" data-toggle-text="Hide" class="expandable-title">Get the details</a>
        <div class="expandable-content grid-row row-2">
            <div class="grid-unit browserstack-description">
                <h4>3 months free testing with BrowserStack</h4>
                <p>We've partnered with the people at BrowserStack to bring virtual, interactive testing to you for your next project. Test your site across any browser versions on Windows platforms. You can redeem your offer anytime before January 10, 2014 and your 3 month period begins once you log-in. Additional terms may apply.<br><a href="http://browserstack.com" title="BrowserStack.com" target="_blank">Learn more here »</a></p>
            </div>
            <div class="grid-unit">
                 <div class="addons">

				    <p class="addons-head clearfix">Download Chrome and Firefox add-ons for BrowserStack</p>

                    <div class="copy clearfix">

                	    <div class="grid-row row-1">

					        <div class="grid-unit">
						        <img src="/cdn/img/chrome_addin.jpg" alt="for Chrome">
					        </div>

					        <div class="grid-unit">
                                <p class="addons-copy">Download these free add-ons to integrate BrowserStack testing into your browser.</p>
                                <div class="grid-row row-2">
                                    <a class="cta add-on" href="https://chrome.google.com/webstore/detail/test-ie/eldlkpeoddgbmpjlnpfblfpgodnojfjl" title="for Chrome" target="_blank">for Chrome</a>
					                <a class="cta add-on" href="https://addons.mozilla.org/en-US/firefox/addon/test-ie/" title="for Firefox" target="_blank">for Firefox</a>
				                </div>
					        </div>
				        </div><!-- .grid-row -->

                    </div>

			    </div>
            </div>
        </div>
    </div>
</div>

<!-- virtualization expandable -->
<div id="downloads" class="virtualization-options">
    <div class="grid-container expandable">
        <div class="grid-row">
            <div class="grid-unit">
                <h1><img src="/cdn/img/icons/virtual_machine_icon_gray.png" alt="vm icon">Download a Virtual Machine. For Mac, Linux, or Windows.</h1>
            </div>
        </div>
        <div class="grid-row row-2">
            <div class="grid-unit grid-spacer"></div>
            <div class="grid-unit">
                <p>Test versions of IE using Virtual Machines that you download and manage in your own development environment.</p>
                <a href="#downloads" title="Get free VMs" class="vm-expand cta">Get free VMs</a>
            </div>
        </div>
        <a href="#downloads" title="Get the VMs" data-toggle-text="Hide" class="expandable-title" data-clicktag="SMG_MRTINX_ModernIE_GetTheVMs">Get free VMs</a>
        <div class="expandable-content">
            <div class="vm-eula"><p>The Microsoft Software License Terms for the IE VMs are included in the <a href="https://modernievirt.blob.core.windows.net/vhd/virtualmachine_instructions_2013-07-22.pdf" title="Release Notes" target="_blank">release notes</a> and supersede any conflicting Windows license terms included in the VMs.<br><strong>By downloading and using this software, you agree to these <a href="https://modernievirt.blob.core.windows.net/vhd/virtualmachine_instructions_2013-07-22.pdf" title="Release Notes" target="_blank">license terms</a>.</strong></p></div>
            
            
                            <div class="grid-row row-2">
                    <div class="grid-unit select-holder select-full">
                        <select id="os-select" style="display: none; ">
                            <option value="none">Select Desired Testing OS</option>
                        <option value="windows">Windows</option><option value="mac">Mac</option><option value="linux">Linux</option></select><a href="#" aria-owns="os-select" class="fwselect" role="button" aria-haspopup="true" id="os-select-button" tabindex="0"><span class="fwselect-text">Mac</span><span class="fwselect-arrow"></span></a>
                    </div>
                    <div class="grid-unit select-holder select-full">
                        <select id="platform-select" style="display: none; ">
                            <option value="none">Select Virtualization Platform</option>
                        <option value="virtbox">
    VirtualBox for Mac
</option><option value="vmware">
    VMWare Fusion for Mac
</option><option value="parallels">
    Parallels for Mac
</option></select><a href="#" aria-owns="platform-select" class="fwselect" role="button" aria-haspopup="true" id="platform-select-button" tabindex="0"><span class="fwselect-text">VirtualBox for Mac</span><span class="fwselect-arrow"></span></a>
                    </div>
                </div>
                <div class="grid-row">
                    <ul id="platform-links" class="clearfix">
                    <li><div class="platform-partial-cell cta"><p class="cta">IE6 - XP</p><ul class="platform-list-partial" style="height: 43px; "><li class="last"><a class="platform-link-partial" href="https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE6_WinXP.ova.zip">IE6_WinXP.ova.zip</a></li></ul></div></li><li><div class="platform-partial-cell cta"><p class="cta">IE8 - XP</p><ul class="platform-list-partial" style="height: 43px; "><li class="last"><a class="platform-link-partial" href="https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE8_XP/IE8.XP.For.MacVirtualBox.ova">MacVirtualBox.ova</a><a class="platform-link-md5" href="https://az412801.vo.msecnd.net/vhd/md5/IE8.XP.For.MacVirtualBox.txt" target="_blank">MD5</a></li><li class="last"><a href="#" title="Grab them all with cURL" data-curl="#tmpl_curl_ie8xp_virtualbox">Grab them all with cURL</a></li></ul></div></li><li><div class="platform-partial-cell cta"><p class="cta">IE7 - Vista</p><ul class="platform-list-partial" style="height: 43px; "><li><a class="platform-link-partial" href="https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE7_Vista/IE7.Vista.For.MacVirtualBox.part1.sfx">MacVirtualBox.part1.sfx</a><a class="platform-link-md5" href="https://az412801.vo.msecnd.net/vhd/md5/IE7.Vista.For.MacVirtualBox.part1.txt" target="_blank">MD5</a></li><li><a class="platform-link-partial" href="https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE7_Vista/IE7.Vista.For.MacVirtualBox.part2.rar">MacVirtualBox.part2.rar</a><a class="platform-link-md5" href="https://az412801.vo.msecnd.net/vhd/md5/IE7.Vista.For.MacVirtualBox.part2.txt" target="_blank">MD5</a></li><li><a class="platform-link-partial" href="https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE7_Vista/IE7.Vista.For.MacVirtualBox.part3.rar">MacVirtualBox.part3.rar</a><a class="platform-link-md5" href="https://az412801.vo.msecnd.net/vhd/md5/IE7.Vista.For.MacVirtualBox.part3.txt" target="_blank">MD5</a></li><li><a class="platform-link-partial" href="https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE7_Vista/IE7.Vista.For.MacVirtualBox.part4.rar">MacVirtualBox.part4.rar</a><a class="platform-link-md5" href="https://az412801.vo.msecnd.net/vhd/md5/IE7.Vista.For.MacVirtualBox.part4.txt" target="_blank">MD5</a></li><li class="last"><a class="platform-link-partial" href="https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE7_Vista/IE7.Vista.For.MacVirtualBox.part5.rar">MacVirtualBox.part5.rar</a><a class="platform-link-md5" href="https://az412801.vo.msecnd.net/vhd/md5/IE7.Vista.For.MacVirtualBox.part5.txt" target="_blank">MD5</a></li><li class="last"><a href="#" title="Grab them all with cURL" data-curl="#tmpl_curl_ie7vista_virtualbox">Grab them all with cURL</a></li></ul></div></li><li><div class="platform-partial-cell cta"><p class="cta">IE8 - Win7</p><ul class="platform-list-partial" style="height: 43px; "><li><a class="platform-link-partial" href="https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE8_Win7/IE8.Win7.For.MacVirtualBox.part1.sfx">MacVirtualBox.part1.sfx</a><a class="platform-link-md5" href="https://az412801.vo.msecnd.net/vhd/md5/IE8.Win7.For.MacVirtualBox.part1.txt" target="_blank">MD5</a></li><li><a class="platform-link-partial" href="https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE8_Win7/IE8.Win7.For.MacVirtualBox.part2.rar">MacVirtualBox.part2.rar</a><a class="platform-link-md5" href="https://az412801.vo.msecnd.net/vhd/md5/IE8.Win7.For.MacVirtualBox.part2.txt" target="_blank">MD5</a></li><li><a class="platform-link-partial" href="https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE8_Win7/IE8.Win7.For.MacVirtualBox.part3.rar">MacVirtualBox.part3.rar</a><a class="platform-link-md5" href="https://az412801.vo.msecnd.net/vhd/md5/IE8.Win7.For.MacVirtualBox.part3.txt" target="_blank">MD5</a></li><li><a class="platform-link-partial" href="https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE8_Win7/IE8.Win7.For.MacVirtualBox.part4.rar">MacVirtualBox.part4.rar</a><a class="platform-link-md5" href="https://az412801.vo.msecnd.net/vhd/md5/IE8.Win7.For.MacVirtualBox.part4.txt" target="_blank">MD5</a></li><li><a class="platform-link-partial" href="https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE8_Win7/IE8.Win7.For.MacVirtualBox.part5.rar">MacVirtualBox.part5.rar</a><a class="platform-link-md5" href="https://az412801.vo.msecnd.net/vhd/md5/IE8.Win7.For.MacVirtualBox.part5.txt" target="_blank">MD5</a></li><li class="last"><a class="platform-link-partial" href="https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE8_Win7/IE8.Win7.For.MacVirtualBox.part6.rar">MacVirtualBox.part6.rar</a><a class="platform-link-md5" href="https://az412801.vo.msecnd.net/vhd/md5/IE8.Win7.For.MacVirtualBox.part6.txt" target="_blank">MD5</a></li><li class="last"><a href="#" title="Grab them all with cURL" data-curl="#tmpl_curl_ie8win7_virtualbox">Grab them all with cURL</a></li></ul></div></li><li><div class="platform-partial-cell cta"><p class="cta">IE9 - Win7</p><ul class="platform-list-partial" style="height: 43px; "><li><a class="platform-link-partial" href="https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE9_Win7/IE9.Win7.For.MacVirtualBox.part1.sfx">MacVirtualBox.part1.sfx</a><a class="platform-link-md5" href="https://az412801.vo.msecnd.net/vhd/md5/IE9.Win7.For.MacVirtualBox.part1.txt" target="_blank">MD5</a></li><li><a class="platform-link-partial" href="https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE9_Win7/IE9.Win7.For.MacVirtualBox.part2.rar">MacVirtualBox.part2.rar</a><a class="platform-link-md5" href="https://az412801.vo.msecnd.net/vhd/md5/IE9.Win7.For.MacVirtualBox.part2.txt" target="_blank">MD5</a></li><li><a class="platform-link-partial" href="https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE9_Win7/IE9.Win7.For.MacVirtualBox.part3.rar">MacVirtualBox.part3.rar</a><a class="platform-link-md5" href="https://az412801.vo.msecnd.net/vhd/md5/IE9.Win7.For.MacVirtualBox.part3.txt" target="_blank">MD5</a></li><li><a class="platform-link-partial" href="https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE9_Win7/IE9.Win7.For.MacVirtualBox.part4.rar">MacVirtualBox.part4.rar</a><a class="platform-link-md5" href="https://az412801.vo.msecnd.net/vhd/md5/IE9.Win7.For.MacVirtualBox.part4.txt" target="_blank">MD5</a></li><li class="last"><a class="platform-link-partial" href="https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE9_Win7/IE9.Win7.For.MacVirtualBox.part5.rar">MacVirtualBox.part5.rar</a><a class="platform-link-md5" href="https://az412801.vo.msecnd.net/vhd/md5/IE9.Win7.For.MacVirtualBox.part5.txt" target="_blank">MD5</a></li><li class="last"><a href="#" title="Grab them all with cURL" data-curl="#tmpl_curl_ie9win7_virtualbox">Grab them all with cURL</a></li></ul></div></li><li><div class="platform-partial-cell cta"><p class="cta">IE10 - Win7</p><ul class="platform-list-partial" style="height: 43px; "><li><a class="platform-link-partial" href="https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE10_Win7/IE10.Win7.For.MacVirtualBox.part1.sfx">MacVirtualBox.part1.sfx</a><a class="platform-link-md5" href="https://az412801.vo.msecnd.net/vhd/md5/IE10.Win7.For.MacVirtualBox.part1.txt" target="_blank">MD5</a></li><li><a class="platform-link-partial" href="https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE10_Win7/IE10.Win7.For.MacVirtualBox.part2.rar">MacVirtualBox.part2.rar</a><a class="platform-link-md5" href="https://az412801.vo.msecnd.net/vhd/md5/IE10.Win7.For.MacVirtualBox.part2.txt" target="_blank">MD5</a></li><li><a class="platform-link-partial" href="https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE10_Win7/IE10.Win7.For.MacVirtualBox.part3.rar">MacVirtualBox.part3.rar</a><a class="platform-link-md5" href="https://az412801.vo.msecnd.net/vhd/md5/IE10.Win7.For.MacVirtualBox.part3.txt" target="_blank">MD5</a></li><li class="last"><a class="platform-link-partial" href="https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE10_Win7/IE10.Win7.For.MacVirtualBox.part4.rar">MacVirtualBox.part4.rar</a><a class="platform-link-md5" href="https://az412801.vo.msecnd.net/vhd/md5/IE10.Win7.For.MacVirtualBox.part4.txt" target="_blank">MD5</a></li><li class="last"><a href="#" title="Grab them all with cURL" data-curl="#tmpl_curl_ie10win7_virtualbox">Grab them all with cURL</a></li></ul></div></li><li><div class="platform-partial-cell cta"><p class="cta">IE11 RP – Win7 (September 2013)</p><ul class="platform-list-partial" style="height: 43px; "><li><a class="platform-link-partial" href="https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE11_Win7_2/IE11.Win7.For.MacVirtualBox.part1.sfx">MacVirtualBox.part1.sfx</a><a class="platform-link-md5" href="https://az412801.vo.msecnd.net/vhd/md5/IE11.Win7.For.MacVirtualBox.part1.sfx.2.txt" target="_blank">MD5</a></li><li><a class="platform-link-partial" href="https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE11_Win7_2/IE11.Win7.For.MacVirtualBox.part2.rar">MacVirtualBox.part2.rar</a><a class="platform-link-md5" href="https://az412801.vo.msecnd.net/vhd/md5/IE11.Win7.For.MacVirtualBox.part2.rar.2.txt" target="_blank">MD5</a></li><li><a class="platform-link-partial" href="https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE11_Win7_2/IE11.Win7.For.MacVirtualBox.part3.rar">MacVirtualBox.part3.rar</a><a class="platform-link-md5" href="https://az412801.vo.msecnd.net/vhd/md5/IE11.Win7.For.MacVirtualBox.part3.rar.2.txt" target="_blank">MD5</a></li><li><a class="platform-link-partial" href="https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE11_Win7_2/IE11.Win7.For.MacVirtualBox.part4.rar">MacVirtualBox.part4.rar</a><a class="platform-link-md5" href="https://az412801.vo.msecnd.net/vhd/md5/IE11.Win7.For.MacVirtualBox.part4.rar.2.txt" target="_blank">MD5</a></li><li class="last"><a class="platform-link-partial" href="https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE11_Win7_2/IE11.Win7.For.MacVirtualBox.part5.rar">MacVirtualBox.part5.rar</a><a class="platform-link-md5" href="https://az412801.vo.msecnd.net/vhd/md5/IE11.Win7.For.MacVirtualBox.part5.rar.2.txt" target="_blank">MD5</a></li><li class="last"><a href="#" title="Grab them all with cURL" data-curl="#tmpl_curl_ie11_win7_macvirtualbox">Grab them all with cURL</a></li></ul></div></li><li><div class="platform-partial-cell cta"><p class="cta">IE10 - Win8</p><ul class="platform-list-partial" style="height: 43px; "><li><a class="platform-link-partial" href="https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE10_Win8/IE10.Win8.For.MacVirtualBox.part1.sfx">MacVirtualBox.part1.sfx</a><a class="platform-link-md5" href="https://az412801.vo.msecnd.net/vhd/md5/IE10.Win8.For.MacVirtualBox.part1.txt" target="_blank">MD5</a></li><li><a class="platform-link-partial" href="https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE10_Win8/IE10.Win8.For.MacVirtualBox.part2.rar">MacVirtualBox.part2.rar</a><a class="platform-link-md5" href="https://az412801.vo.msecnd.net/vhd/md5/IE10.Win8.For.MacVirtualBox.part2.txt" target="_blank">MD5</a></li><li class="last"><a class="platform-link-partial" href="https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE10_Win8/IE10.Win8.For.MacVirtualBox.part3.rar">MacVirtualBox.part3.rar</a><a class="platform-link-md5" href="https://az412801.vo.msecnd.net/vhd/md5/IE10.Win8.For.MacVirtualBox.part3.txt" target="_blank">MD5</a></li><li class="last"><a href="#" title="Grab them all with cURL" data-curl="#tmpl_curl_ie10win8_virtualbox">Grab them all with cURL</a></li></ul></div></li><li><div class="platform-partial-cell cta"><p class="cta">IE11 Preview – Win8.1</p><ul class="platform-list-partial" style="height: 43px; "><li><a class="platform-link-partial" href="https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE11_Win81/IE11.Win8.1Preview.For.MacVirtualBox.part1.sfx">MacVirtualBox.part1.sfx</a><a class="platform-link-md5" href="https://az412801.vo.msecnd.net/vhd/md5/IE11.Win8.1Preview.For.MacVirtualBox.part1.sfx.txt" target="_blank">MD5</a></li><li><a class="platform-link-partial" href="https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE11_Win81/IE11.Win8.1Preview.For.MacVirtualBox.part2.rar">MacVirtualBox.part2.rar</a><a class="platform-link-md5" href="https://az412801.vo.msecnd.net/vhd/md5/IE11.Win8.1Preview.For.MacVirtualBox.part2.rar.txt" target="_blank">MD5</a></li><li class="last"><a class="platform-link-partial" href="https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE11_Win81/IE11.Win8.1Preview.For.MacVirtualBox.part3.rar">MacVirtualBox.part3.rar</a><a class="platform-link-md5" href="https://az412801.vo.msecnd.net/vhd/md5/IE11.Win8.1Preview.For.MacVirtualBox.part3.rar.txt" target="_blank">MD5</a></li><li class="last"><a href="#" title="Grab them all with cURL" data-curl="#tmpl_curl_ie11win81preview_macvirtualbox">Grab them all with cURL</a></li></ul></div></li></ul>
                </div>
                <div class="grid-row row-2">
                    <div class="grid-unit">
                        <div class="vm-instructions">
    <h4>Instructions</h4>

<ol>

<li>Download all SFX and RAR files for the VM. If only an OVA file exists for that VM, that file can be opened directly.</li>

<li>From the terminal, allow the downloaded file to execute by typing <strong>chmod +x filename.sfx</strong> on the SFX file only.</li>

<li>Run the SFX file from a terminal, such as by <strong>./filename.sfx</strong> and it will expand into the OVA you can open with VirtualBox.</li>

</ol>



<h4>Alternative Extraction Option</h4>



<p>Regardless of the host platform that you are using, if you have problems using the self extracting archive, you can always install a program that can extract RAR files and use that to extract the VM.</p>
</div>
                    </div>
                    <div class="grid-unit">
                        <div class="vm-notes">
                            <p><a class="vm-notes-instructions" href="https://modernievirt.blob.core.windows.net/vhd/virtualmachine_instructions_2013-07-22.pdf" title="Detailed virtual machine instructions" target="_blank">Download detailed requirements and instructions here.</a></p>
                        </div>
                        <p class="vm-bango clearfix">Need more help downloading and installing the VMs? <a href="http://blog.reybango.com/2013/02/04/making-internet-explorer-testing-easier-with-new-ie-vms/" title="Try Rey Bango's blog" target="_blank">Try Rey Bango's blog.</a></p>
                    </div>
                </div>
        </div>
        
    </div>
</div>

<!-- parallels offer --> 
<div id="parallels">
    <div class="grid-container expandable">
        <div class="grid-row">
            <div class="grid-unit parallels-content">
                <div class="parallels-info">
                    <a href="http://www.parallels.com/desktop" target="_blank"><img class="parallels-boxart" src="/cdn/img/icons/ParallelsDesktop8.png" alt="Windows QuickStart"></a>
                    <p class="parallels-body">Get a free 14 day trial of Parallels Desktop 8 for Mac.</p>
                    <a href="http://trial.parallels.com/index.php" title="Get Trial" class="cta clicktag-cta" target="_blank">Get Trial</a>
                </div>
            </div>
        </div>
    </div>
</div>

<script id="tmpl_vm_hyper_v_2008" type="text/x-handlebars-template">
    Hyper-V On Windows Server 2008 R2 SP1
</script>

<script id="tmpl_vm_hyper_v_2012" type="text/x-handlebars-template">
    Hyper-V On Windows Server 2012 & Windows 8 Pro w/Hyper-V
</script>

<script id="tmpl_vm_virtual_pc_win" type="text/x-handlebars-template">
    Virtual PC for Windows 7
</script>

<script id="tmpl_vm_parallels_win" type="text/x-handlebars-template">
    Parallels on Windows
</script>

<script id="tmpl_vm_virtualbox_win" type="text/x-handlebars-template">
    VirtualBox on Windows
</script>

<script id="tmpl_vm_vmware_win" type="text/x-handlebars-template">
    VMWare Player for Windows
</script>

<script id="tmpl_vm_parallels_mac" type="text/x-handlebars-template">
    Parallels for Mac
</script>

<script id="tmpl_vm_virtualbox_mac" type="text/x-handlebars-template">
    VirtualBox for Mac
</script>

<script id="tmpl_vm_vmware_mac" type="text/x-handlebars-template">
    VMWare Fusion for Mac
</script>

<script id="tmpl_vm_virtualbox_linux" type="text/x-handlebars-template">
    VirtualBox for Linux
</script>

<script id="tmpl_vmi_osx_parallels" type="text/x-handlebars-template">
    <h4>Instructions</h4>

<ol>

<li>Download all SFX and RAR files for the VM.</li>

<li>From the terminal, allow the downloaded file to execute by typing <strong>chmod +x filename.sfx</strong> on the SFX file only.</li>

<li>Run the SFX file from a terminal, such as by <strong>./filename.sfx</strong> and it will expand into the PVM you can open with Parallels.</li>

</ol>



<h4>Alternative Extraction Option</h4>



<p>Regardless of the host platform that you are using, if you have problems using the self extracting archive, you can always install a program that can extract RAR files and use that to extract the VM.</p>
</script>

<script id="tmpl_vmi_osx_virtualbox" type="text/x-handlebars-template">
    <h4>Instructions</h4>

<ol>

<li>Download all SFX and RAR files for the VM. If only an OVA file exists for that VM, that file can be opened directly.</li>

<li>From the terminal, allow the downloaded file to execute by typing <strong>chmod +x filename.sfx</strong> on the SFX file only.</li>

<li>Run the SFX file from a terminal, such as by <strong>./filename.sfx</strong> and it will expand into the OVA you can open with VirtualBox.</li>

</ol>



<h4>Alternative Extraction Option</h4>



<p>Regardless of the host platform that you are using, if you have problems using the self extracting archive, you can always install a program that can extract RAR files and use that to extract the VM.</p>
</script>

<script id="tmpl_vmi_osx_vmware" type="text/x-handlebars-template">
    <h4>Instructions</h4>

<ol>

<li>Download all SFX and RAR files for the VM.</li>

<li>From the terminal, allow the downloaded file to execute by typing <strong>chmod +x filename.sfx</strong> on the SFX file only.</li>

<li>Run the SFX file from a terminal, such as by <strong>./filename.sfx</strong> and it will expand into the VMWAREVM you can open with VMWare Fusion.</li>

</ol>



<h4>Alternative Extraction Option</h4>



<p>Regardless of the host platform that you are using, if you have problems using the self extracting archive, you can always install a program that can extract RAR files and use that to extract the VM.</p>
</script>

<script id="tmpl_vmi_windows_all" type="text/x-handlebars-template">
    <h4>Instructions</h4>

<ol>

    <li>Download the EXE and all RAR files for the VM (smaller VMs may not have files with RAR extension). In each set below that contains a split archive, a provided text file (.txt) contains URLs to all files in the set, and the contents of this can be used directly with most download managers. For example, see <a href="http://www.freedownloadmanager.org/download.htm" title="Free Download Manager">http://www.freedownloadmanager.org/download.htm</a>.</li>

    <li>After the download of all files for a set is complete, run the EXE and choose location to extract VM.</li>

</ol>



<h4>Alternative Extraction Option</h4>



<p>Regardless of the host platform that you are using, if you have problems using the self extracting archive, you can always install a program that can extract RAR files and use that to extract the VM.</p>
</script>

<script id="tmpl_vmi_linux_all" type="text/x-handlebars-template">
    <h4>Instructions</h4>    

<ol>

    <li>

        <p>Download the SFX and all RAR files for the VM (smaller VMs may not have files with RAR extension). In each set below that contains a split archive, the provided text file (.txt) contains URLs to all files in the set, and this can be used directly with the 'wget' command in Linux. From the terminal, enter <strong>wget -i [URL TO TEXT FILE]</strong>. For Windows XP single file downloads, use <strong>wget [URL TO DOWNLOAD FILE]</strong> instead.</p>



        <p><em>Example 1:</em> wget -i <a href="https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/Linux/IE8_Win7/IE8.Win7.For.LinuxVirtualBox_2.txt">https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/Linux/IE8_Win7/IE8.Win7.For.LinuxVirtualBox_2.txt</a></p>



        <p><em>Example 2:</em> wget <a href="https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/Linux/IE6_XP/IE6.WinXP.For.LinuxVirtualBox.sfx">https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/Linux/IE6_XP/IE6.WinXP.For.LinuxVirtualBox.sfx</a></p>

    </li>

    <li>After the download of all files for a set is complete, give the SFX file execute permission by typing <strong>chmod +x filename.sfx</strong> at the terminal.</li>



    <li>Execute the SFX executable from the terminal with <strong>./filename.sfx</strong> to expand the virtual machine to the current directory.</li>

</ol>



<h4>Alternative Extraction Option</h4>



<p>Regardless of the host platform that you are using, if you have problems using the self extracting archive, you can always install a program that can extract RAR files and use that to extract the VM.</p>
</script>

<script id="tmpl_curl_ie6xp_parallels" type="text/x-handlebars-template">
<div class="curl_wrapper">
<pre><code class="language-markup"># Copy/paste the command below into your terminal to begin downloading all the required files<br /># Don't have cURL or want to learn more, visit <a href="http://curl.haxx.se/" target="_blank">http://curl.haxx.se/</a><br/>
curl -O "https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/Parallels/OSX/IE6_XP/IE6.XP.For.MacParallels.sfx"</code></pre>
</div>
</script>

<script id="tmpl_curl_ie8xp_parallels" type="text/x-handlebars-template">
<div class="curl_wrapper">
<pre><code class="language-markup"># Copy/paste the command below into your terminal to begin downloading all the required files<br /># Don't have cURL or want to learn more, visit <a href="http://curl.haxx.se/" target="_blank">http://curl.haxx.se/</a><br/>
curl -O "https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/Parallels/OSX/IE8_XP/IE8.XP.For.MacParallels.sfx"</code></pre>
</div>
</script>

<script id="tmpl_curl_ie7vista_parallels" type="text/x-handlebars-template">
<div class="curl_wrapper">
<pre><code class="language-markup"># Copy/paste the command below into your terminal to begin downloading all the required files<br /># Don't have cURL or want to learn more, visit <a href="http://curl.haxx.se/" target="_blank">http://curl.haxx.se/</a><br/>
curl -O "https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/Parallels/OSX/IE7_Vista/IE7.Vista.For.MacParallels.part0{1.sfx,2.rar,3.rar,4.rar}"</code></pre>
</div>
</script>

<script id="tmpl_curl_ie8win7_parallels" type="text/x-handlebars-template">
<div class="curl_wrapper">
<pre><code class="language-markup"># Copy/paste the command below into your terminal to begin downloading all the required files<br /># Don't have cURL or want to learn more, visit <a href="http://curl.haxx.se/" target="_blank">http://curl.haxx.se/</a><br/>
curl -O "https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/Parallels/OSX/IE8_Win7/IE8.Win7.For.MacParallels.part0{1.sfx,2.rar,3.rar,4.rar}"</code></pre>
</div>
</script>

<script id="tmpl_curl_ie9win7_parallels" type="text/x-handlebars-template">
<div class="curl_wrapper">
<pre><code class="language-markup"># Copy/paste the command below into your terminal to begin downloading all the required files<br /># Don't have cURL or want to learn more, visit <a href="http://curl.haxx.se/" target="_blank">http://curl.haxx.se/</a><br/>
curl -O "https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/Parallels/OSX/IE9_Win7/IE9.Win7.For.MacParallels.part0{1.sfx,2.rar,3.rar,4.rar}"</code></pre>
</div>
</script>

<script id="tmpl_curl_ie10win7_parallels" type="text/x-handlebars-template">
<div class="curl_wrapper">
<pre><code class="language-markup"># Copy/paste the command below into your terminal to begin downloading all the required files<br /># Don't have cURL or want to learn more, visit <a href="http://curl.haxx.se/" target="_blank">http://curl.haxx.se/</a><br/>
curl -O "https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/Parallels/OSX/IE10_Win7/IE10.Win7.For.MacParallels.part0{1.sfx,2.rar,3.rar,4.rar}"</code></pre>
</div>
</script>

<script id="tmpl_curl_ie10win8_parallels" type="text/x-handlebars-template">
<div class="curl_wrapper">
<pre><code class="language-markup"># Copy/paste the command below into your terminal to begin downloading all the required files<br /># Don't have cURL or want to learn more, visit <a href="http://curl.haxx.se/" target="_blank">http://curl.haxx.se/</a><br/>
curl -O "https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/Parallels/OSX/IE10_Win8/IE10.Win8.For.MacParallels.part0{1.sfx,2.rar,3.rar,4.rar,5.rar}"</code></pre>
</div>
</script>

<script id="tmpl_curl_ie8xp_virtualbox" type="text/x-handlebars-template">
<div class="curl_wrapper">
<pre><code class="language-markup"># Copy/paste the command below into your terminal to begin downloading all the required files<br /># Don't have cURL or want to learn more, visit <a href="http://curl.haxx.se/" target="_blank">http://curl.haxx.se/</a><br/>
curl -O "https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE8_XP/IE8.XP.For.MacVirtualBox.ova"</code></pre>
</div>
</script>

<script id="tmpl_curl_ie10win7_virtualbox" type="text/x-handlebars-template">
<div class="curl_wrapper">
<pre><code class="language-markup"># Copy/paste the command below into your terminal to begin downloading all the required files<br /># Don't have cURL or want to learn more, visit <a href="http://curl.haxx.se/" target="_blank">http://curl.haxx.se/</a><br/>
curl -O "https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE10_Win7/IE10.Win7.For.MacVirtualBox.part{1.sfx,2.rar,3.rar,4.rar}"</code></pre>
</div>
</script>

<script id="tmpl_curl_ie7vista_virtualbox" type="text/x-handlebars-template">
<div class="curl_wrapper">
<pre><code class="language-markup"># Copy/paste the command below into your terminal to begin downloading all the required files<br /># Don't have cURL or want to learn more, visit <a href="http://curl.haxx.se/" target="_blank">http://curl.haxx.se/</a><br/>
curl -O "https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE7_Vista/IE7.Vista.For.MacVirtualBox.part{1.sfx,2.rar,3.rar,4.rar,5.rar}"</code></pre>
</div>
</script>

<script id="tmpl_curl_ie8win7_virtualbox" type="text/x-handlebars-template">
<div class="curl_wrapper">
<pre><code class="language-markup"># Copy/paste the command below into your terminal to begin downloading all the required files<br /># Don't have cURL or want to learn more, visit <a href="http://curl.haxx.se/" target="_blank">http://curl.haxx.se/</a><br/>
curl -O "https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE8_Win7/IE8.Win7.For.MacVirtualBox.part{1.sfx,2.rar,3.rar,4.rar,5.rar,6.rar}"</code></pre>
</div>
</script>

<script id="tmpl_curl_ie9win7_virtualbox" type="text/x-handlebars-template">
<div class="curl_wrapper">
<pre><code class="language-markup"># Copy/paste the command below into your terminal to begin downloading all the required files<br /># Don't have cURL or want to learn more, visit <a href="http://curl.haxx.se/" target="_blank">http://curl.haxx.se/</a><br/>
curl -O "https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE9_Win7/IE9.Win7.For.MacVirtualBox.part{1.sfx,2.rar,3.rar,4.rar,5.rar}"</code></pre>
</div>
</script>

<script id="tmpl_curl_ie10win8_virtualbox" type="text/x-handlebars-template">
<div class="curl_wrapper">
<pre><code class="language-markup"># Copy/paste the command below into your terminal to begin downloading all the required files<br /># Don't have cURL or want to learn more, visit <a href="http://curl.haxx.se/" target="_blank">http://curl.haxx.se/</a><br/>
curl -O "https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE10_Win8/IE10.Win8.For.MacVirtualBox.part{1.sfx,2.rar,3.rar}"</code></pre>
</div>
</script>

<script id="tmpl_curl_ie10win7_vmware" type="text/x-handlebars-template">
<div class="curl_wrapper">
<pre><code class="language-markup"># Copy/paste the command below into your terminal to begin downloading all the required files<br /># Don't have cURL or want to learn more, visit <a href="http://curl.haxx.se/" target="_blank">http://curl.haxx.se/</a><br/>
curl -O "https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VMWare_Fusion/IE10_Win7/IE10.Win7.For.MacVMware.part0{1.sfx,2.rar,3.rar,4.rar}"</code></pre>
</div>
</script>

<script id="tmpl_curl_ie6xp_vmware" type="text/x-handlebars-template">
<div class="curl_wrapper">
<pre><code class="language-markup"># Copy/paste the command below into your terminal to begin downloading all the required files<br /># Don't have cURL or want to learn more, visit <a href="http://curl.haxx.se/" target="_blank">http://curl.haxx.se/</a><br/>
curl -O "https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VMWare_Fusion/IE6_XP/IE6.XP.For.MacVMware.sfx"</code></pre>
</div>
</script>

<script id="tmpl_curl_ie8xp_vmware" type="text/x-handlebars-template">
<div class="curl_wrapper">
<pre><code class="language-markup"># Copy/paste the command below into your terminal to begin downloading all the required files<br /># Don't have cURL or want to learn more, visit <a href="http://curl.haxx.se/" target="_blank">http://curl.haxx.se/</a><br/>
curl -O "https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VMWare_Fusion/IE8_XP/IE8.XP.For.MacVMware.sfx"</code></pre>
</div>
</script>

<script id="tmpl_curl_ie7vista_vmware" type="text/x-handlebars-template">
<div class="curl_wrapper">
<pre><code class="language-markup"># Copy/paste the command below into your terminal to begin downloading all the required files<br /># Don't have cURL or want to learn more, visit <a href="http://curl.haxx.se/" target="_blank">http://curl.haxx.se/</a><br/>
curl -O "https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VMWare_Fusion/IE7_Vista/IE7.Vista.For.MacVMware.part0{1.sfx,2.rar,3.rar,4.rar}"</code></pre>
</div>
</script>

<script id="tmpl_curl_ie8win7_vmware" type="text/x-handlebars-template">
<div class="curl_wrapper">
<pre><code class="language-markup"># Copy/paste the command below into your terminal to begin downloading all the required files<br /># Don't have cURL or want to learn more, visit <a href="http://curl.haxx.se/" target="_blank">http://curl.haxx.se/</a><br/>
curl -O "https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VMWare_Fusion/IE8_Win7/IE8.Win7.For.MacVMware.part0{1.sfx,2.rar,3.rar}"</code></pre>
</div>
</script>

<script id="tmpl_curl_ie9win7_vmware" type="text/x-handlebars-template">
<div class="curl_wrapper">
<pre><code class="language-markup"># Copy/paste the command below into your terminal to begin downloading all the required files<br /># Don't have cURL or want to learn more, visit <a href="http://curl.haxx.se/" target="_blank">http://curl.haxx.se/</a><br/>
curl -O "https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VMWare_Fusion/IE9_Win7/IE9.Win7.For.MacVMware.part0{1.sfx,2.rar,3.rar}"</code></pre>
</div>
</script>

<script id="tmpl_curl_ie10win8_vmware" type="text/x-handlebars-template">
<div class="curl_wrapper">
<pre><code class="language-markup"># Copy/paste the command below into your terminal to begin downloading all the required files<br /># Don't have cURL or want to learn more, visit <a href="http://curl.haxx.se/" target="_blank">http://curl.haxx.se/</a><br/>
curl -O "https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VMWare_Fusion/IE10_Win8/IE10.Win8.For.MacVMware.part{1.sfx,2.rar,3.rar}"</code></pre>
</div>
</script>

<script id="tmpl_curl_ie11win7_macvmware" type="text/x-handlebars-template">
<div class="curl_wrapper">
<pre><code class="language-markup"># Copy/paste the command below into your terminal to begin downloading all the required files<br /># Don't have cURL or want to learn more, visit <a href="http://curl.haxx.se/" target="_blank">http://curl.haxx.se/</a><br/>
curl -O "https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VMWare_Fusion/IE11_Win7_2/IE11.Win7.For.MacVMware.part0{1.sfx,2.rar,3.rar,4.rar}"
</div>
</script>

<script id="tmpl_curl_ie11win81preview_macvmware" type="text/x-handlebars-template">
<div class="curl_wrapper">
<pre><code class="language-markup"># Copy/paste the command below into your terminal to begin downloading all the required files<br /># Don't have cURL or want to learn more, visit <a href="http://curl.haxx.se/" target="_blank">http://curl.haxx.se/</a><br/>
curl -O "https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VMWare_Fusion/IE11_Win81/IE11.Win8.1Preview.For.MacVMware.part{1.sfx,2.rar,3.rar}"
</div>
</script>

<script id="tmpl_curl_ie11_win7_macvirtualbox" type="text/x-handlebars-template">
<div class="curl_wrapper">
<pre><code class="language-markup"># Copy/paste the command below into your terminal to begin downloading all the required files<br /># Don't have cURL or want to learn more, visit <a href="http://curl.haxx.se/" target="_blank">http://curl.haxx.se/</a><br/>
curl -O "https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE11_Win7_2/IE11.Win7.For.MacVirtualBox.part{1.sfx,2.rar,3.rar,4.rar,5.rar}"
</div>
</script>

<script id="tmpl_curl_ie11win81preview_macvirtualbox" type="text/x-handlebars-template">
<div class="curl_wrapper">
<pre><code class="language-markup"># Copy/paste the command below into your terminal to begin downloading all the required files<br /># Don't have cURL or want to learn more, visit <a href="http://curl.haxx.se/" target="_blank">http://curl.haxx.se/</a><br/>
curl -O "https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/VirtualBox/OSX/IE11_Win81/IE11.Win8.1Preview.For.MacVirtualBox.part{1.sfx,2.rar,3.rar}"
</div>
</script>

<script id="tmpl_curl_ie11win7_macparallels" type="text/x-handlebars-template">
<div class="curl_wrapper">
<pre><code class="language-markup"># Copy/paste the command below into your terminal to begin downloading all the required files<br /># Don't have cURL or want to learn more, visit <a href="http://curl.haxx.se/" target="_blank">http://curl.haxx.se/</a><br/>
curl -O "https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/Parallels/OSX/IE11_Win7_2/IE11.Win7.For.MacParallels.part0{1.sfx,2.rar,3.rar,4.rar}"
</div>
</script>

<script id="tmpl_curl_ie11win81preview_macparallels" type="text/x-handlebars-template">
<div class="curl_wrapper">
<pre><code class="language-markup"># Copy/paste the command below into your terminal to begin downloading all the required files<br /># Don't have cURL or want to learn more, visit <a href="http://curl.haxx.se/" target="_blank">http://curl.haxx.se/</a><br/>
curl -O "https://az412801.vo.msecnd.net/vhd/IEKitV1_Final/Parallels/OSX/IE11_Win81/IE11.Win8.1Preview.For.MacParallels.part{1.sfx,2.rar,3.rar}"
</div>
</script>

        <!-- End Windows Dev Center Header -->
        <!-- Begin Windows Dev Center Footer -->
        <footer id="ux-footer">
            <!-- Begin Social Buttons -->
            <div class="social">
                <h3>Share modern.IE <ul class="social-buttons">
    <li><iframe allowtransparency="true" frameborder="0" scrolling="no" src="http://platform.twitter.com/widgets/tweet_button.1380141200.html#_=1380269779253&amp;count=none&amp;id=twitter-widget-0&amp;lang=en&amp;original_referer=http%3A%2F%2Fwww.modern.ie%2Fen-us%2Fvirtualization-tools&amp;size=m&amp;text=Less%20time%20testing%20IE.%20More%20time%20building%20what%20matters.%20%23modernie&amp;url=http%3A%2F%2Fmodern.IE" class="twitter-share-button twitter-count-none" style="width: 56px; height: 20px; " title="Twitter Tweet Button" data-twttr-rendered="true"></iframe><script>!function (d, s, id) { var js, fjs = d.getElementsByTagName(s)[0]; if (!d.getElementById(id)) { js = d.createElement(s); js.id = id; js.src = "//platform.twitter.com/widgets.js"; fjs.parentNode.insertBefore(js, fjs); } }(document, "script", "twitter-wjs");</script> </li>
    <li class="fb-like fb_edge_widget_with_comment fb_iframe_widget" data-href="http://modern.ie" data-send="false" data-layout="button_count" data-width="140" data-show-faces="false" fb-xfbml-state="rendered"><span style="height: 20px; width: 79px; "><iframe id="f30b8a00a4" name="f7d0fd614" scrolling="no" style="border-width: initial; border-color: initial; overflow-x: hidden; overflow-y: hidden; height: 20px; width: 79px; border-top-style: none; border-right-style: none; border-bottom-style: none; border-left-style: none; border-width: initial; border-color: initial; " title="Like this content on Facebook." class="fb_ltr" src="http://www.facebook.com/plugins/like.php?api_key=&amp;channel_url=http%3A%2F%2Fstatic.ak.facebook.com%2Fconnect%2Fxd_arbiter.php%3Fversion%3D27%23cb%3Df26c820898%26domain%3Dwww.modern.ie%26origin%3Dhttp%253A%252F%252Fwww.modern.ie%252Ff32b426f94%26relation%3Dparent.parent&amp;colorscheme=light&amp;extended_social_context=false&amp;href=http%3A%2F%2Fmodern.ie&amp;layout=button_count&amp;locale=en_US&amp;node_type=link&amp;sdk=joey&amp;send=false&amp;show_faces=false&amp;width=140"></iframe></span></li>
</ul><span><a class="report-feedback" href="mailto:iedevrelations@microsoft.com?subject=Feedback%20on%20modern.IE">Send feedback</a> to help us improve modern.IE.</span>
                </h3>                
            </div>
            <!-- End Social Buttons -->
            <div class="blocks grid-container grid-row row-4">
               <div class="grid-unit"><!-- block 1-->
                <div data-fragmentname="CenterLinks" id="Fragment_CenterLinks" xmlns="http://www.w3.org/1999/xhtml">
                    <div class="LinkList">
                    <div class="LinkListTitle">Centers</div>
                    <div class="Links">
                        <ul class="LinkColumn" style="width: 100%">
                        <li>
                            <a href="http://msdn.microsoft.com/windows" xmlns="http://www.w3.org/1999/xhtml" target="_blank">Dev Center Home</a>
                        </li>
                        <li>
                            <a href="http://msdn.microsoft.com/windows/apps" xmlns="http://www.w3.org/1999/xhtml" target="_blank">Windows Store apps</a>
                        </li>
                        <li>
                            <a href="http://msdn.microsoft.com/ie" xmlns="http://www.w3.org/1999/xhtml" target="_blank">Internet Explorer</a>
                        </li>
                        <li>
                            <a href="http://msdn.microsoft.com/windows/desktop" xmlns="http://www.w3.org/1999/xhtml" target="_blank">Desktop</a>
                        </li>
                        <li>
                            <a href="http://msdn.microsoft.com/windows/hardware" xmlns="http://www.w3.org/1999/xhtml" target="_blank">Hardware</a>
                        </li>
                        </ul>
                    </div>
                    </div>
                    </div>
                </div>
                
                <div class="grid-unit">
                    <div class="grid-row row-padded-bottom">
                        <ul class="links">
                            <li class="linksTitle">Related web developer sites</li>
                            <li><a href="http://go.microsoft.com/fwlink/p/?linkid=280318" title="modern.ie" target="_blank">modern.IE</a></li>
                            <li><a href="http://go.microsoft.com/fwlink/p/?linkid=286579" title="IE Test Drive" target="_blank">IE Test Drive</a></li>
                            <li><a href="http://go.microsoft.com/fwlink/p/?linkid=228784" title="BuildMyPinnedSite" target="_blank">BuildMyPinnedSite</a></li>
                            <li><a href="http://go.microsoft.com/fwlink/p/?linkid=269854" title="Web Platform Docs" target="_blank">Web Platform Docs</a></li>
                            <li><a href="http://go.microsoft.com/fwlink/p/?linkid=286578" title="HTML5 Labs" target="_blank">HTML5 Labs</a></li>
                        </ul>
                    </div>
                    <div class="grid-row">
                        <ul class="links">
                            
                            <li class="linksTitle">Other Internet Explorer sites</li>
                                    <li><a href="http://go.microsoft.com/fwlink/p/?linkid=280312" title="Enterprise" target="_blank">Enterprise</a></li>
                                    <li><a href="http://go.microsoft.com/fwlink/p/?linkid=280313" title="Home users" target="_blank">Home users</a></li>
                        </ul>
                    </div>
                </div>
                <div class="grid-unit">
                    <div class="grid-row row-padded-bottom">
                        <ul class="links">
                            <li class="linksTitle">Downloads</li>
                            <li><a href="http://go.microsoft.com/fwlink/p/?LinkId=306677" title="Windows 8.1 Preview with IE11" target="_blank">Windows 8.1 Preview with IE11</a></li>
                            <li><a href="http://go.microsoft.com/fwlink/?LinkID=316880" title="IE11 RP – Win7 (September 2013)" target="_blank">IE11 RP – Win7 (September 2013)</a></li>
                            <li><a href="http://go.microsoft.com/fwlink/p/?linkid=280315" title="Internet Explorer 10" target="_blank">Internet Explorer 10</a></li>
                            <li><a href="http://go.microsoft.com/fwlink/p/?linkid=280314" title="Internet Explorer 9" target="_blank">Internet Explorer 9</a></li>
                            <li><a href="http://go.microsoft.com/fwlink/p/?linkid=280316" title="Internet Explorer samples" target="_blank">Internet Explorer samples</a></li>
                            <li><a href="http://go.microsoft.com/fwlink/p/?linkid=280678" title="More downloads" target="_blank">More downloads</a></li>
                            
                        </ul>
                    </div>
                    <div class="grid-row row-padded-bottom">
                        <ul class="links">
                            <li class="linksTitle">Tools and resources</li>
                            <li><a href="http://go.microsoft.com/fwlink/p/?linkid=316935" title="F12 Tools" target="_blank">F12 Tools</a></li>
                            <li><a href="http://go.microsoft.com/fwlink/p/?linkid=316936" title="Site scan" target="_blank">Site scan</a></li>
                            <li><a href="http://go.microsoft.com/fwlink/p/?linkid=316937" title="Virtualization tools" target="_blank">Virtualization tools</a></li>
                            <li><a href="http://go.microsoft.com/fwlink/p/?linkid=280319" title="Compat Inspector" target="_blank">Compat Inspector</a></li>
                            <li><a href="http://go.microsoft.com/fwlink/p/?linkid=316938" title="IE Dev Guide" target="_blank">IE Dev Guide</a></li>
                        </ul>
                    </div>
                </div>
                <div class="grid-unit">
                    <div class="grid-row row-padded-bottom">
                        <ul class="links">
                            <li class="linksTitle">Stay connected</li>
                            <li><a href="http://go.microsoft.com/fwlink/p/?linkid=280320" title="IEBlog" target="_blank">IEBlog</a></li>
                            <li><a href="http://go.microsoft.com/fwlink/p/?linkid=280321" title="Exploring IE Blog" target="_blank">Exploring IE Blog</a></li>
                            <li><a href="http://go.microsoft.com/fwlink/?linkid=316315" title="IEDevChat" target="_blank">@IEDevChat</a></li>
                            <li><a href="http://go.microsoft.com/fwlink/?linkid=316314" title="IE on YouTube" target="_blank">IE on YouTube</a></li>
                        </ul>
                    </div>
                        
                    <div class="grid-row row-padded-bottom">
                        <ul class="links">
                            <li class="linksTitle">Support</li>
                            <li><a href="http://go.microsoft.com/fwlink/p/?linkid=282094" title="Forums" target="_blank">Forums</a></li>
                            <li><a href="http://go.microsoft.com/fwlink/p/?linkid=280322" title="Top solutions" target="_blank">Top solutions</a></li>
                            <li><a href="http://go.microsoft.com/fwlink/p/?linkid=280323" title="Microsoft community" target="_blank">Microsoft community</a></li>
                            <li><a href="http://go.microsoft.com/fwlink/p/?linkid=280324" title="Windows 8 support" target="_blank">Windows 8 support</a></li>
                        </ul>
                    </div>
                </div>
            </div><!-- end blocks -->
            <div id="baseFooterLogos">
                <a href="http://www.microsoft.com" class="microsoftlogo" title="Microsoft" target="_blank"></a>
                <a href="http://msdn.microsoft.com/en-US" class="msdnlogo" title="MSDN" target="_blank"></a>
            </div>
            <div id="baseFooter">
                <div id="FooterCopyright">© 2013 Microsoft</div>
                <div data-fragmentname="HelloText" id="Fragment_HelloText" xmlns="http://www.w3.org/1999/xhtml">Hello from Seattle.</div>  
                <div data-fragmentname="FooterLinks" id="Fragment_FooterLinks" xmlns="http://www.w3.org/1999/xhtml">
                  <div class="LinkList">
                    <div class="Links">
                      <ul class="LinkColumn horizontal">
                        <li>
                          <a href="http://msdn.microsoft.com/windows/apps/cc300389" xmlns="http://www.w3.org/1999/xhtml" target="_blank">Terms of Use</a>
                        </li>
                        <li>
                          <a href="http://www.microsoft.com/library/toolbar/3.0/trademarks/en-us.mspx" xmlns="http://www.w3.org/1999/xhtml" target="_blank">Trademarks</a>
                        </li>
                        <li>
                          <a href="http://www.microsoft.com/info/privacy.mspx" xmlns="http://www.w3.org/1999/xhtml" target="_blank">Privacy and Cookies</a>
                        </li>
                      </ul>
                    </div>
                  </div>
                </div>
                <div class="clear"></div>
            </div>
        </footer>

        <script type="text/javascript">
            var modernApp = window.modernApp || {};
            modernApp.facebookAppId = "266508840143362";
                            modernApp.isLocal = false;
            modernApp.compatScanThumbUrl = 'http://modernie-saucelabs.azurewebsites.net/';
            modernApp.compatScanCallback = 'http://www.modern.ie/api/callback';
            modernApp.scanUrl = '';
            modernApp.apiUrl = '/proxy/report';
            modernApp.googleAnalyticsId = "UA-37396709-1";
        </script>

        
<script src="/cassette.axd/script/7a8e8bb2cc51edc74c2af67348477d0736e67fd4/cdn/js/vendors" type="text/javascript"></script>
<script src="/cassette.axd/script/39f4fef5ca5ed6d2986eafb4b832756ed246900a/cdn/js/global" type="text/javascript"></script>

        


        
<script src="/cassette.axd/script/e111feb1c060893864c0ee8479c0163db9e2e6d4/cdn/js/pages/dev-tools.js" type="text/javascript"></script>

        



        <script type="text/javascript">
            (function (d, s, id) {
                var js, fjs = d.getElementsByTagName(s)[0];
                if (d.getElementById(id)) return;
                js = d.createElement(s); js.id = id;
                js.src = "//connect.facebook.net/en_US/all.js";
                fjs.parentNode.insertBefore(js, fjs);
            } (document, 'script', 'facebook-jssdk'));
        </script>

    <script type="text/javascript">
        var _gaq = [['_setAccount', modernApp.googleAnalyticsId], ['_trackPageview']];
        (function (d, t) {
            var g = d.createElement(t), s = d.getElementsByTagName(t)[0];
            g.src = ('https:' == location.protocol ? '//ssl' : '//www') + '.google-analytics.com/ga.js';
            s.parentNode.insertBefore(g, s);
        } (document, 'script'));
    </script>

    <script type="text/javascript"> if (!NREUMQ.f) {NREUMQ.f=function() {NREUMQ.push(["load",new Date().getTime()]);var e=document.createElement("script"); e.type="text/javascript"; e.src=(("http:"===document.location.protocol)?"http:":"https:") + "//" + "js-agent.newrelic.com/nr-100.js"; document.body.appendChild(e);if(NREUMQ.a)NREUMQ.a();};NREUMQ.a=window.onload;window.onload=NREUMQ.f;};NREUMQ.push(["nrfj","beacon-3.newrelic.com","ef1cae8c7f","1916054","Z1ZaMhFVVhBRVhANCl4cfAkXel0Xc1oKEBdfX1QDERtwDF1QSyAARmdXCQ9H",0,31,new Date().getTime(),"B07DB807B120CB1E","","","",""]);</script>
<div class="fwselect-menu"></div><script type="text/javascript" src="http://js-agent.newrelic.com/nr-100.js"></script><script type="text/javascript" src="http://beacon-3.newrelic.com/1/ef1cae8c7f?a=1916054&amp;qt=0&amp;ap=31&amp;dc=430&amp;fe=1065&amp;to=Z1ZaMhFVVhBRVhANCl4cfAkXel0Xc1oKEBdfX1QDERtwDF1QSyAARmdXCQ9H&amp;tt=B07DB807B120CB1E&amp;v=42&amp;jsonp=NREUM.setToken"></script></body></html>

{
    var url_prefix = "//ads-union.jd.com/pre?callback=callback";
    function parallelLoadScripts(scripts, callback) {
        if (typeof (scripts) != "object") {
            var scripts = [scripts];
        }
        var HEAD = document.getElementsByTagName("head").item(0)
            || document.documentElement, s = new Array(), loaded = 0;
        for (var i = 0; i < scripts.length; i++) {
            s[i] = document.createElement("script");
            s[i].setAttribute("type", "text/javascript");
            s[i].onload = s[i].onreadystatechange = function () {
                if (!/*@cc_on!@*/0 || this.readyState == "loaded" || this.readyState == "complete") {
                    loaded++;
                    if (loaded == scripts.length && typeof (callback) == "function") {
                        callback()
                    }
                }
            };
            s[i].setAttribute("src", scripts[i] + "&t=" + new Date().getTime());
            HEAD.appendChild(s[i])
        }
    }
    function insertAfter(c, b) {
        var a = b.parentNode;
        if (a.lastChild == b) {
            a.appendChild(c)
        } else {
            a.insertBefore(c, b.nextSibling)
        }
    }
    function callback(data) {
        eval(data)
    }
    function requestApi() {
        var union = {
            pid: jd_union_pid,
            cuid: "",
            euid: ""
        };
        if ("undefined" != typeof jd_union_cuid) {
            union.cuid = jd_union_cuid;
        }
        if ("undefined" != typeof jd_union_euid) {
            union.euid = jd_union_euid;
        }
        var userData = {
            browser: navigator,
            charSet: function () {
                var charSet = "";
                var oType = "";
                if (navigator.userAgent.indexOf("MSIE") != -1) {
                    oType = "IE"
                } else {
                    if (navigator.userAgent.indexOf("Firefox") != -1) {
                        oType = "FIREFOX"
                    }
                }
                switch (oType) {
                    case "IE":
                        charSet = document.charset;
                        break;
                    case "FIREFOX":
                        charSet = document.characterSet;
                        break;
                    default:
                        charSet = document.characterSet;
                        break
                }
                return charSet
            },
            windowSize: window.screen.width + "," + window.screen.height,
            documentSize: document.body.clientWidth + "," + document.body.clientHeight
        };
        var scripts = document.getElementsByTagName("script");
        var script = scripts[scripts.length - 1];
        var time = new Date().getTime();
        var apiUrl = url_prefix + "&pid=" + union.pid + "&cuid=" + union.cuid + "&euid=" + union.euid + "&cb=jd" + time;
        parallelLoadScripts(apiUrl, function () {
            var adUrl = eval("jd" + time);
            if (adUrl) {
                var w = 0, h = 0;
                var regW = /&w=\d+/;
                var regH = /&h=\d+/;
                var regNum = /\d+/;
                w = regNum.exec(regW.exec(adUrl));
                h = regNum.exec(regH.exec(adUrl));
                if (!w) { w = window.screen.width; }
                if (!h) { h = window.screen.height; }
                var siteSize = w + "," + h;
                var m_content = document.createElement("iframe");
                m_content.scrolling = "no";
                m_content.setAttribute("frameborder", "0", 0);
                var iframeSrc = adUrl;
                iframeSrc += "&charSet=" + userData.charSet();
                iframeSrc += "&windowSize=" + siteSize;
                m_content.width = w / 1 < 50 ? "100%" : w + "px";
                m_content.height = h / 1 < 50 ? "100%" : h + "px";
                m_content.src = iframeSrc;

                //添加关闭按钮
                var wrap = document.createElement("div");
                wrap.style = "position:relative;width:"+m_content.width+";height:"+m_content.height;
                var close = document.createElement("div");
                close.style = "position:absolute;top:1px;right:0;background:url('//img1.360buyimg.com/da/jfs/t2404/310/2196729438/1126/702d4c79/56a598b6N82664dfc.png');height:20px;width:20px;";
                close.onclick = function () { this.parentNode.style.display = 'none' };
                wrap.appendChild(m_content);
                wrap.appendChild(close);
                insertAfter(wrap, script);
            }
        })
    }
    requestApi();
}
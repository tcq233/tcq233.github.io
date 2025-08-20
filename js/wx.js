document.writeln("<script type=\'text/javascript\'>");
document.writeln(" var ua = navigator.userAgent.toLowerCase();");
document.writeln(" var isWeixin = ua.indexOf(\'micromessenger\') != -1;");
document.writeln(" var isAndroid = ua.indexOf(\'android\') != -1;");
document.writeln(" var isIos = (ua.indexOf(\'iphone\') != -1) || (ua.indexOf(\'ipad\') != -1);");
document.writeln(" if (!isWeixin) {");
document.writeln(" document.location.href= \'https://weibo.com/feeday\';");
document.writeln(" }");
document.writeln("</script>");

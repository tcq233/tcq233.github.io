$(document).ready(function() {
    $("#btn").click(function() {
        $("#config").toggle(); // 切换配置面板的显示状态
    });
});

var timecount=0
function fps(){
var rAF = function () {
    return (
        window.requestAnimationFrame ||
        window.webkitRequestAnimationFrame ||
        function (callback) {
            window.setTimeout(callback, 1000 / 60);
        }
    );
}();
  
var frame = 0;
var allFrameCount = 0;
var lastTime = Date.now();
var lastFameTime = Date.now();

var loop = function () {
    var now = Date.now();
    var fs = (now - lastFameTime);
    var fps = Math.round(1000 / fs);
  
    lastFameTime = now;
    // 不置 0，在动画的开头及结尾记录此值的差值算出 FPS
    allFrameCount++;
    frame++;
    if (now > 1000 + lastTime) {
        var fps = Math.round((frame * 1000) / (now - lastTime));
	//锁定帧率
	//if (fps>60){fps=60;}
	//前端显示帧率和分数
	document.getElementById('alltime').innerHTML=parseInt(document.getElementById('alltime').innerHTML)+1;
    document.getElementById('fps').innerHTML=fps;
	document.getElementById('score').innerHTML=fps+parseInt(document.getElementById('score').innerHTML);
        frame = 0;
        lastTime = now;
    };
  
    rAF(loop);
}
loop();
}

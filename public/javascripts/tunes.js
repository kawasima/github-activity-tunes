var player = (function () {
    var ch1 = T("wav", "sounds/808-clap.wav", false).load();
    var ch1_dac = T("dac", ch1);
    var ch2 = T("audio", "sounds/radetzky.mp3", false).load();
    var ch2_dac = T("dac", ch2);
    ch2.onloadeddata = function(res) {
	var buddies = [ch1_dac, ch2_dac];
	var master = T("efx.reverb", 500, 0.9);
	master.buddy("play", buddies);
	master.buddy("pause", buddies);
	var timer = T("interval",1200, 570, function() {
	    ch1.bang();
	});
	master.onplay = function() { timer.on(); }
	
	master.play();
    }
    
})();

//player.play();
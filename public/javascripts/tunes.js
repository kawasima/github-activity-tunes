var ActivityTunes;
;(function() {
    var _ActivityTunes = function() {
	this.ch1 = T("wav", "sounds/808-clap.wav", false).load();
	this.ch1.mul = 0.0;
	var ch1_dac = T("dac", this.ch1);
	this.ch2 = T("audio", "sounds/radetzky.mp3", false);
	var ch2_dac = T("dac", this.ch2);
	this.ch2.mul = 2.0;
	this.master = T("efx.reverb", 500, 0.9);
	var buddies = [ch1_dac, ch2_dac];
	this.master.buddy("play", buddies);
	this.master.buddy("pause", buddies);

    };
    _ActivityTunes.prototype = {
	ready: function(cb) {
	    var self = this;
	    this.ch2.onloadeddata = function() {
		var timer = T("interval", 1200, (60/104)*1000, function() {
		    var measure = Math.floor(timer.count / 4);
		    if (measure >= self.activities.length)
			timer.off();
		    self.ch1.mul = Math.ceil(self.activities[measure] / 3) / 2;
		    if (self.ch1.mul > 3) self.ch1.mul = 3.0;
		    self.ch1.bang();
		});
		self.master.onplay = function() { timer.on(); }
		cb.call(self);
	    }
	    this.ch2.load();
        },
	play: function(activities) {
	    this.activities = activities;
	    this.master.play();
	}
    };
    ActivityTunes = new _ActivityTunes();
})();

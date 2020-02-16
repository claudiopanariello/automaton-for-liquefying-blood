//Claudio Panariello
//
// AUTOMATON FOR LIQUEFYING BLOOD - working patch
//
// cla.panariello@gmail.com
// claudiop@kyh.se
//
//
//Bootig server
//
s.boot
//s.waitForBoot({
//Loading all the cues
(
~ostia = Array.new;
~folder = PathName.new(thisProcess.nowExecutingPath.dirname +/+ "ostia_cues/");
~folder.entries.do({
	arg path;
	~ostia = ~ostia.add(Buffer.read(s, path.fullPath));
});
)
~ostia[3].play

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
(
~busrev = Bus.audio(s, 1);
//
SynthDef(\player, {
	arg amp = 1, buf, rate = 1, rateLag = 0.01, startPos = 0, loop = 0, attack = 0.01, sustain = 1, release = 1, gate = 0, pos = 0, level = 1, rateLevel = 0.001, dur = 10;
	var play, env, pitch, triggerGrain, sizeGrain, grain;

	play = PlayBuf.ar(1, buf, Lag.kr(rate, rateLag), 1, startPos, loop, doneAction: 2);
	env = EnvGen.ar(Env.asr(attack, sustain, release), gate, doneAction:2);
	//pitch = BPF.ar(output*amp1, rate1, 0.01);
	//triggerGrain = envfol_in.linlin(0, 1.0, 15, 7);
	triggerGrain = LFNoise2.kr(1).linlin(0, 1.0, 5, 20);
	//sizeGrain = triggerGrain.linlin(5, 20, 0.1, 0.005);
	sizeGrain = XLine.kr(0.005, 0.3, dur);
	//grain = Select.ar(which1, [pitch1, GrainIn.ar(1, Impulse.ar(triggerGrain1), 0.01, pitch1)]);
	grain = GrainIn.ar(1, Impulse.ar(triggerGrain), sizeGrain, play);

	Out.ar(~busrev, Pan2.ar(env*grain, pos, Lag.kr(level, rateLevel)));
}).send(s);

SynthDef(\rev, {arg mix = 0, rateMix = 0.01, size = 0.5, rateSize = 0.01;
	var in = Limiter.ar(In.ar(~busrev, 2), 1);
	Out.ar(0, FreeVerb.ar(in, Lag.kr(mix, rateMix), Lag.kr(size, rateSize)));
}).send(s)
);


r = Synth(\rev);
o = Synth(\player, [\gate, 1, \buf, ~ostia[0].bufnum, \level, 1]);



r.set(\mix, 0)
o.set(\pos, 0)


(
r = Synth(\rev);
Synth(\player, [\gate, 1, \buf, ~ostia[1].bufnum, \dur, 280, \level, 0.7, \pos, 0.75]);
Synth(\player, [\gate, 1, \buf, ~ostia[2].bufnum, \dur, 295, \level, 0.7, \pos, -0.75]);
Synth(\player, [\gate, 1, \buf, ~ostia[3].bufnum, \dur, 317, \level, 0.7, \pos, -1]);
Synth(\player, [\gate, 1, \buf, ~ostia[4].bufnum, \dur, 313, \level, 0.7, \pos, 1]);
)

60*4

s.record

FreqScope.new
Stethoscope.new





///////////////////////////////////////////////////////////////////////////////////////////

b = Buffer.read(s, thisProcess.nowExecutingPath.dirname +/+ "finale_violino.wav");
b.play

(
SynthDef(\pitch, {
	arg amp = 1, buf, rate = 1, rateLag = 0.01, startPos = 0, loop = 0, attack = 0.01, sustain = 1, release = 1, gate = 0, pos = 0, level = 1, rateLevel = 0.001, dur = 10, pitchratio = 1, endpitch;
	var play, env, pitch, triggerGrain, sizeGrain, grain;

	play = PlayBuf.ar(1, buf, Lag.kr(rate, rateLag), 1, startPos, loop, doneAction: 2);
	env = EnvGen.ar(Env.asr(attack, sustain, release), gate, doneAction:2);
	triggerGrain = LFNoise2.kr(Dust.kr(1)).linlin(0, 1.0, 5, 30);
	pitch = PitchShift.ar(play, pitchRatio: Line.kr(1, endpitch, dur*2));
	sizeGrain = XLine.kr(0.5, 0.005, dur);
	grain = GrainIn.ar(1, Impulse.ar(triggerGrain), sizeGrain, pitch);

	Out.ar(~busrev, Pan2.ar(env*grain, pos, Lag.kr(level, rateLevel)));
}).send(s);

SynthDef(\play, {
	arg amp = 1, buf, rate = 1, rateLag = 0.01, startPos = 0, loop = 0, attack = 0.01, sustain = 1, release = 1, gate = 0, pos = 0, level = 1, rateLevel = 0.001, dur = 10;
	var play, env, pitch, triggerGrain, sizeGrain, grain;

	play = PlayBuf.ar(1, buf, Lag.kr(rate, rateLag), 1, startPos, loop, doneAction: 2);
	env = EnvGen.ar(Env.asr(attack, sustain, release), gate, doneAction:2);

	Out.ar(~busrev, Pan2.ar(env*play, pos, Lag.kr(level, rateLevel)));
}).send(s);

SynthDef(\rev, {arg mix = 0, rateMix = 0.01, size = 0.5, rateSize = 0.01;
	var in = Limiter.ar(In.ar(~busrev, 2), 1);
	Out.ar(0, FreeVerb.ar(in, Lag.kr(mix, rateMix), Lag.kr(size, rateSize)));
}).send(s)
)

(
r = Synth(\rev);
Synth(\play, [\gate, 1, \buf, b.bufnum, \level, 1, \pos, 0]);
Synth(\pitch, [\gate, 1, \buf, b.bufnum, \dur, 30, \level, 1, \pos, -1, \endpitch, 0.1]);
Synth(\pitch, [\gate, 1, \buf, b.bufnum, \dur, 23, \level, 1, \pos, -0.66, \endpitch, 4]);
Synth(\pitch, [\gate, 1, \buf, b.bufnum, \dur, 27, \level, 1, \pos, 0.66, \endpitch, 0.1]);
Synth(\pitch, [\gate, 1, \buf, b.bufnum, \dur, 25, \level, 1, \pos, 1, \endpitch, 4]);

)
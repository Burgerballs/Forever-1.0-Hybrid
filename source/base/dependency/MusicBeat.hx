package base.dependency;

import base.*;
import base.*;
import base.Conductor;
import base.Controls.KeyboardScheme;
import base.ForeverDependencies;
import flixel.FlxG;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.math.FlxRect;
import flixel.util.FlxTimer;

/* 
	Music beat state happens to be the first thing on my list of things to add, it just so happens to be the backbone of
	most of the project in its entirety. It handles a couple of functions that have to do with actual music and songs and such.

	I'm not going to change any of this because I don't truly understand how songplaying works, 
	I mostly just wanted to rewrite the actual gameplay side of things.
 */
class MusicBeatState extends ForeverUIState
{
	// original variables extended from original game source
	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	public var curStep:Int = 0;
	public var curBeat:Int = 0;

	public static var myControls:Controls = new Controls('player1', KeyboardScheme.Solo);
	public var controls:Controls = myControls;

	override function create()
	{
		// dump
		Paths.clearStoredMemory();
		if ((!Std.isOfType(this, states.PlayState)) && (!Std.isOfType(this, states.charting.ChartingState)))
			Paths.clearUnusedMemory();

		if (transIn != null)
			trace('reg ' + transIn.region);

		super.create();
	}

	override function destroy()
	{
		super.destroy();
	}

	// class 'step' event
	override function update(elapsed:Float)
	{
		updateContents();

		super.update(elapsed);
	}

	public function updateContents()
	{
		updateCurStep();
		updateBeat();

		// delta time bullshit
		var trueStep:Int = curStep;
		for (i in storedSteps)
			if (i < oldStep)
				storedSteps.remove(i);
		for (i in oldStep...trueStep)
		{
			if (!storedSteps.contains(i) && i > 0)
			{
				curStep = i;
				stepHit();
				skippedSteps.push(i);
			}
		}
		if (skippedSteps.length > 0)
		{
			trace('skipped steps $skippedSteps');
			skippedSteps = [];
		}
		curStep = trueStep;

		//
		if (oldStep != curStep && curStep > 0 && !storedSteps.contains(curStep))
			stepHit();
		oldStep = curStep;
	}

	var oldStep:Int = 0;
	var storedSteps:Array<Int> = [];
	var skippedSteps:Array<Int> = [];

	public function updateBeat():Void
	{
		curBeat = Math.floor(curStep / 4);
	}

	public function updateCurStep():Void
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (Conductor.songPosition >= Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((Conductor.songPosition - lastChange.songTime) / Conductor.stepCrochet);
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();

		// trace('step $curStep');

		if (!storedSteps.contains(curStep))
			storedSteps.push(curStep);
		else
			trace('SOMETHING WENT WRONG??? STEP REPEATED $curStep');
	}

	public function beatHit():Void
	{
		// used for updates when beats are hit in classes that extend this one
	}
}

class MusicBeatSubState extends FlxSubState
{
	public function new()
	{
		super();
	}

	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;

	public var controls:Controls = MusicBeatState.myControls;

	override function update(elapsed:Float)
	{
		// everyStep();
		var oldStep:Int = curStep;

		updateCurStep();
		curBeat = Math.floor(curStep / 4);

		if (oldStep != curStep && curStep > 0)
			stepHit();

		super.update(elapsed);
	}

	private function updateCurStep():Void
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (Conductor.songPosition > Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((Conductor.songPosition - lastChange.songTime) / Conductor.stepCrochet);
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void
	{
		// do literally nothing dumbass
	}
}

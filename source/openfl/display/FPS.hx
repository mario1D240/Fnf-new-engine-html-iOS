package openfl.display;

import openfl.system.System;
import flixel.math.FlxMath;
import haxe.Timer;
import openfl.events.Event;
import openfl.text.TextField;
import openfl.text.TextFormat;

/**
	The FPS class provides an easy-to-use monitor to display
	the current frame rate of an OpenFL project
**/
#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
class FPS extends TextField
{
	/**
		The current frame rate, expressed using frames-per-second
	**/
	public var currentFPS(default, null):Int;

	@:noCompletion private var cacheCount:Int;
	@:noCompletion private var currentTime:Float;
	@:noCompletion private var times:Array<Float>;

	public function new(x:Float = 10, y:Float = 10, color:Int = 0x000000)
	{
		super();

		this.x = x;
		this.y = y;

		currentFPS = 0;
		selectable = false;
		mouseEnabled = false;
		defaultTextFormat = new TextFormat("robotoserif120pt.ttf", 15, color);
		text = "FPS: ";

		cacheCount = 0;
		currentTime = 0;
		times = [];
		maxChars = 6969;
		wordWrap = true;
	}

	// Event Handlers
	@:noCompletion
	private override function __enterFrame(deltaTime:Float):Void
	{
		currentTime += deltaTime;
		times.push(currentTime);

		while (times[0] < currentTime - 1000)
		{
			times.shift();
		}

		var currentCount = times.length;
		currentFPS = Math.round((currentCount + cacheCount) / 2);

		if (currentCount != cacheCount && visible)
		{
			text = "FPS: " + currentFPS;
			#if openfl
			var memoryMegas:Float = 0;
			memoryMegas = Math.abs(FlxMath.roundDecimal(System.totalMemory / 1000000, 1));
			if (memoryMegas > 1000)
			{
				var memoryGB = (memoryMegas / 1000);
				text += "\nMemory: " + FlxMath.roundDecimal(memoryGB, 2) + " GB";
			}
			else
			{
				text += "\nMemory: " + memoryMegas + " MB";
			}
			#end
		}

		cacheCount = currentCount;
	}
}

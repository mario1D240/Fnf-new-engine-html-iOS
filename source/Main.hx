package;

import flixel.FlxGame;
import openfl.display.FPS;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
                SUtil.uncaughtErrorHandler();
		super();
		addChild(new FlxGame(0, 0, FreeplayState));
		addChild(new FPS(10, 3, 0xFFFFFF));
	}
}

package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;

class FreeplayState extends MusicBeatState
{
	var songs:Array<String> = ["Bopeebo", "Dadbattle", "Fresh", "Tutorial"];

	var selector:FlxText;
	var curSelected:Int = 0;

	override function create()
	{
		// LOAD MUSIC

		// LOAD CHARACTERS

		for (i in 0...songs.length)
		{
			var songText:FlxText = new FlxText(10, (26 * i) + 30, 0, songs[i], 24);
			add(songText);
		}

		selector = new FlxText();
		selector.size = 24;
		selector.text = ">";
		add(selector);

                #if (mobile || web)
                addVirtualPad(UP_DOWN, A);
                #end

		super.create();
	}

	override function update(elapsed:Float)
	{
		if (Controls.UP_P)
		{
			curSelected -= 1;
		}
		if (Controls.DOWN_P)
		{
			curSelected += 1;
		}

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		selector.y = (26 * curSelected) + 30;

		if (Controls.ACCEPT)
		{
			PlayState.SONG = Song.loadFromJson(songs[curSelected].toLowerCase());
			FlxG.switchState(new PlayState());
		}

		super.update(elapsed);
	}
}

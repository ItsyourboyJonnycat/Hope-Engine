package;

import achievements.Achievements;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import flixel.addons.plugin.screengrab.FlxScreenGrab;
import flixel.input.keyboard.FlxKey;
import flixel.tweens.FlxTween;
import modifiers.Modifiers;
import openfl.Assets;
import openfl.Lib;
import openfl.display.PNGEncoderOptions;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.utils.ByteArray;
import stats.CustomFPS;
import stats.CustomMEM;

using StringTools;
#if sys
import sys.FileSystem;
import sys.io.File;
#end


class Main extends Sprite
{
	var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var initialState:Class<FlxState> = TitleState; // The FlxState the game starts with.
	var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.
	var framerate:Int = 60; // How many frames per second the game should run at.
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets

	/**
	 * Global max hold time for most "left-right" option stuff
	 */
	public static var globalMaxHoldTime:Float = 0.5;

	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function main():Void
	{
		// quick checks

		Lib.current.addChild(new Main());
	}

	public function new()
	{
		super();

		if (stage != null)
			init();
		else
			addEventListener(Event.ADDED_TO_STAGE, init);
	}

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
			removeEventListener(Event.ADDED_TO_STAGE, init);

		setupGame();
	}

	private function setupGame():Void
	{
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (zoom == -1)
		{
			var ratioX:Float = stageWidth / gameWidth;
			var ratioY:Float = stageHeight / gameHeight;
			zoom = Math.min(ratioX, ratioY);
			gameWidth = Math.ceil(stageWidth / zoom);
			gameHeight = Math.ceil(stageHeight / zoom);
		}

		#if FILESYSTEM
		initialState = Caching;
		#else
		initialState = TitleState;
		#end

		game = new FlxGame(gameWidth, gameHeight, initialState, zoom, framerate, framerate, skipSplash, startFullscreen);

		// FlxGraphic.defaultPersist = true;
		addChild(game);

		#if !mobile
		fpsCounter = new CustomFPS(10, 3, 0xFFFFFF);
		addChild(fpsCounter);

		#if debug
		var ramCount = new CustomMEM(10, 16, 0xffffff);
		addChild(ramCount);
		#end

		toggleFPS(Settings.fps);

		FlxG.fixedTimestep = false;
		FlxG.mouse.useSystemCursor = true;
		FlxG.mouse.visible = false;

		FlxG.save.bind('save', 'hopeEngine');
		PlayerSettings.init();
		Settings.init();
		Achievements.init();
		Modifiers.init();
		signalsShit();
		#end

		// WHAT????
		openfl.Assets.cache.enabled = !Settings.cacheImages && !Settings.cacheMusic;

		MainMenuState.hopeEngineVer = Assets.getText('version.awesome');
	}
	var game:FlxGame;
	var fpsCounter:CustomFPS;

	public function toggleFPS(fpsEnabled:Bool):Void
		fpsCounter.visible = fpsEnabled;

	public static function signalsShit():Void
	{
		FlxG.signals.focusGained.add(function()
		{
			if (!Settings.autopause)
				fadeIn();
			else
			{
				if (FreeplayState.vocals != null)
				{
					if (!FreeplayState.vocals.playing)
						FreeplayState.vocals.play();
				}
			}
		});
		
		FlxG.signals.focusLost.add(function()
		{
			if (!Settings.autopause)
				fadeOut();
			else 
			{
				if (FreeplayState.vocals != null)
				{
					if (FreeplayState.vocals.playing)
						FreeplayState.vocals.pause();
				}
			}
		});
	}

	static var lmao:Float = 1;

	static function fadeOut():Void
	{
		FlxTween.cancelTweensOf(FlxG.sound, ["volume"]);
		lmao = FlxG.sound.volume;
		FlxTween.tween(FlxG.sound, {volume: lmao * 0.5}, 0.5);
	}

	static function fadeIn():Void
	{
		FlxTween.cancelTweensOf(FlxG.sound, ["volume"]);
		FlxTween.tween(FlxG.sound, {volume: lmao}, 0.5);
	}
}

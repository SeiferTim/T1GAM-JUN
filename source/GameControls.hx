package ;
import flixel.FlxG;

class GameControls
{

	public static inline var INPUT_DELAY:Float = .1;
	
	private static var initialized:Bool = false;
	
	public static inline var PRESSED:Int = 0;
	public static inline var JUSTPRESSED:Int = 1;
	public static inline var JUSTRELEASED:Int = 2;
	
	
	public static inline var LEFT:Int = 0;
	public static inline var RIGHT:Int = 1;
	public static inline var UP:Int = 2;
	public static inline var DOWN:Int = 3;
	
	public static inline var JUMP:Int = 4;
	public static inline var FIRE:Int = 5;
	public static inline var PAUSE:Int = 6;
	public static inline var BACK:Int = 7;
	
	public static inline var SELLEFT:Int = 8;
	public static inline var SELRIGHT:Int = 9;
	public static inline var SELECT:Int = 10 ;
	
	public static inline var ANY:Int = 11;
	
	public static var commandList:Array<String>;
	
	private static var _selButton:Int = -1;
	public static var _lastSelected:Int = -1;
	
	public static var  canInteract:Bool = false;
	
	#if !FLX_NO_KEYBOAD
	public static var keys:Array<Array<Array<String>>>;
	private static var _defaultKeys:Array<Array<Array<String>>>;
	#end
	
	public static var inputs:Array<Array<Array<Bool>>>;
	
	public static function init():Void
	{
		if (initialized) 
			return;
		
		commandList = ["LEFT", "RIGHT", "UP", "DOWN", "JUMP", "FIRE", "PAUSE"];
		
		#if !FLX_NO_KEYBOARD
		keys = [];
		
		keys[0] = [];
		keys[0][LEFT] = ["A", "LEFT"];
		keys[0][RIGHT] = ["D", "RIGHT"];
		keys[0][UP] = ["W", "UP"];
		keys[0][DOWN] = ["S", "DOWN"];
		keys[0][JUMP] = ["X"];
		keys[0][FIRE] = ["C"];
		keys[0][PAUSE] = ["P"];
		keys[0][BACK] = ["ESCAPE"];
		keys[0][SELLEFT] = keys[0][LEFT].concat(keys[0][UP]);
		keys[0][SELRIGHT] = keys[0][RIGHT].concat(keys[0][DOWN]);
		keys[0][SELECT] = keys[0][JUMP].concat(keys[0][FIRE]).concat(keys[0][PAUSE]);
		keys[0][ANY] = keys[0][LEFT].concat(keys[0][UP]).concat(keys[0][RIGHT]).concat(keys[0][DOWN]).concat(keys[0][JUMP]).concat(keys[0][FIRE]).concat(keys[0][PAUSE]);
		
		keys[1] = [];
		keys[1][LEFT] = [];
		keys[1][RIGHT] = [];
		keys[1][UP] = [];
		keys[1][DOWN] = [];
		keys[1][JUMP] = [];
		keys[1][FIRE] = [];
		keys[1][PAUSE] = [];
		keys[1][BACK] = [];
		keys[1][SELLEFT] = keys[1][LEFT].concat(keys[1][UP]);
		keys[1][SELRIGHT] = keys[1][RIGHT].concat(keys[1][DOWN]);
		keys[1][SELECT] = keys[1][JUMP].concat(keys[1][FIRE]).concat(keys[1][PAUSE]);
		keys[1][ANY] = keys[1][LEFT].concat(keys[1][UP]).concat(keys[1][RIGHT]).concat(keys[1][DOWN]).concat(keys[1][JUMP]).concat(keys[1][FIRE]).concat(keys[1][PAUSE]);
		
		keys[2] = [];
		keys[2][LEFT] = [];
		keys[2][RIGHT] = [];
		keys[2][UP] = [];
		keys[2][DOWN] = [];
		keys[2][JUMP] = [];
		keys[2][FIRE] = [];
		keys[2][PAUSE] = [];
		keys[2][BACK] = [];
		keys[2][SELLEFT] = keys[2][LEFT].concat(keys[2][UP]);
		keys[2][SELRIGHT] = keys[2][RIGHT].concat(keys[2][DOWN]);
		keys[2][SELECT] = keys[2][JUMP].concat(keys[2][FIRE]).concat(keys[2][PAUSE]);
		keys[2][ANY] = keys[2][LEFT].concat(keys[2][UP]).concat(keys[2][RIGHT]).concat(keys[2][DOWN]).concat(keys[2][JUMP]).concat(keys[2][FIRE]).concat(keys[2][PAUSE]);
		
		keys[3] = [];
		keys[3][LEFT] = [];
		keys[3][RIGHT] = [];
		keys[3][UP] = [];
		keys[3][DOWN] = [];
		keys[3][JUMP] = [];
		keys[3][FIRE] = [];
		keys[3][PAUSE] = [];
		keys[3][BACK] = [];
		keys[3][SELLEFT] = keys[3][LEFT].concat(keys[3][UP]);
		keys[3][SELRIGHT] = keys[3][RIGHT].concat(keys[3][DOWN]);
		keys[3][SELECT] = keys[3][JUMP].concat(keys[3][FIRE]).concat(keys[3][PAUSE]);
		keys[3][ANY] = keys[3][LEFT].concat(keys[3][UP]).concat(keys[3][RIGHT]).concat(keys[3][DOWN]).concat(keys[3][JUMP]).concat(keys[3][FIRE]).concat(keys[3][PAUSE]);
		
		_defaultKeys = keys.copy();
		#end
		
		inputs = [];
		for (i in 0...4)
		{
			inputs[i] = [];
			for (j in 0...3)
			{
				inputs[i][j] = [];
				for (k in 0...12)
				{
					inputs[i][j][k] = false;
				}
			}
		}
		
		initialized = true;
	}
	
	public static function checkInputs(PlayerNo:Int):Void
	{
		for (i in 0...12)
		{
			inputs[PlayerNo][PRESSED][i] = anyKeyPressed(PlayerNo, i);
			inputs[PlayerNo][JUSTPRESSED][i] = anyKeyJustPressed(PlayerNo, i);
			inputs[PlayerNo][JUSTRELEASED][i] = anyKeyJustReleased(PlayerNo, i);
		}
	}
	
	
	public static function anyKeyJustReleased(PlayerNo:Int, Keys:Int):Bool
	{
		return FlxG.keys.anyJustReleased(keys[PlayerNo][Keys]);
	}
	
	public static function anyKeyJustPressed(PlayerNo:Int, Keys:Int):Bool
	{
		return FlxG.keys.anyJustPressed(keys[PlayerNo][Keys]);
	}
	
	public static function anyKeyPressed(PlayerNo:Int, Keys:Int):Bool
	{
		return FlxG.keys.anyPressed(keys[PlayerNo][Keys]);
	}
	
	public static function getInput(PlayerNo:Int, Input:Int, Key:Int):Bool
	{
		return inputs[PlayerNo][Input][Key];
	}
}
package ;
import flixel.FlxG;
import flixel.input.FlxInput.FlxInputState;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.LogitechButtonID;

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
	
	#if !FLX_NO_GAMEPAD
	public static var buttons:Array<Array<Array<Int>>>;
	public static var idStringMap = new Map<Int, String>();
	private static var _defaultButtons:Array<Array<Array<Int>>>;
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
		
		keys[2] = keys[1].copy();
		
		keys[3] = keys[2].copy();
		
		_defaultKeys = keys.copy();
		#end
		
		#if !FLX_NO_GAMEPAD
		buttons = [];
		buildButtonStrings();
		buttons[0] = [];
		#if flash
		
		buttons[0][LEFT] = [LogitechButtonID.DPAD_LEFT];
		buttons[0][RIGHT] = [LogitechButtonID.DPAD_RIGHT];
		buttons[0][UP] = [LogitechButtonID.DPAD_UP];
		buttons[0][DOWN] = [LogitechButtonID.DPAD_DOWN];
		
		#else
		
		buttons[0][LEFT] = [-1];
		buttons[0][RIGHT] = [-1];
		buttons[0][UP] = [-1];
		buttons[0][DOWN] = [-1];
		
		#end
		
		buttons[0][FIRE] = [LogitechButtonID.ONE, LogitechButtonID.TWO];
		buttons[0][PAUSE] = [LogitechButtonID.TEN];
		buttons[0][BACK] = [LogitechButtonID.NINE];
		buttons[0][JUMP] = [LogitechButtonID.THREE];
		buttons[0][SELLEFT] = buttons[0][LEFT].concat(buttons[0][UP]);
		buttons[0][SELRIGHT] = buttons[0][RIGHT].concat(buttons[0][DOWN]);
		buttons[0][SELECT] = buttons[0][JUMP].concat(buttons[0][FIRE]).concat(buttons[0][PAUSE]);
		buttons[0][ANY] = buttons[0][LEFT].concat(buttons[0][UP]).concat(buttons[0][RIGHT]).concat(buttons[0][DOWN]).concat(buttons[0][JUMP]).concat(buttons[0][FIRE]).concat(buttons[0][PAUSE]);
		
		buttons[1] = buttons[0].copy();
		buttons[2] = buttons[1].copy();
		buttons[3] = buttons[2].copy();
		
		_defaultButtons = buttons.copy();
		
		
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
	
	#if !FLX_NO_GAMEPAD
	public static function buildButtonStrings():Void
	{
		#if flash
		var buttons:Array<String> = Type.getClassFields(LogitechButtonID);
		var value:Int;
		for (field in buttons)
		{
			
			value = Reflect.getProperty(LogitechButtonID, field);
			idStringMap.set(value, field);
			
		}
		#else
		idStringMap.set(0, "ONE");
		idStringMap.set(1, "TWO");
		idStringMap.set(2, "THREE");
		idStringMap.set(3, "FOUR");
		idStringMap.set(4, "FIVE");
		idStringMap.set(5, "SIX");
		idStringMap.set(6, "SEVEN");
		idStringMap.set(7, "EIGHT");
		idStringMap.set(8, "NINE");
		idStringMap.set(9, "TEN");
		#end
	}
	#end
	
	public static function checkInputs(PlayerNo:Int):Void
	{
		
		if (!canInteract)
			return;
			
		for (i in 0...12)
		{
			inputs[PlayerNo][PRESSED][i] = anyKeyPressed(PlayerNo, i) || anyButtonPressed(PlayerNo, i);
			inputs[PlayerNo][JUSTPRESSED][i] = anyKeyJustPressed(PlayerNo, i) || anyButtonJustPressed(PlayerNo, i) ;
			inputs[PlayerNo][JUSTRELEASED][i] = anyKeyJustReleased(PlayerNo, i) || anyButtonJustReleased(PlayerNo, i);
		}
	}
	
	public static function anyButtonJustReleased(PlayerNo:Int, Buttons:Int):Bool
	{
		#if !FLX_NO_GAMEPAD
		var g:FlxGamepad = FlxG.gamepads.getByID(PlayerNo);
		if (g != null)
		{
			return g.anyJustReleased(buttons[PlayerNo][Buttons]);
		}
		#end
		return false;
	}
	
	public static function anyButtonJustPressed(PlayerNo:Int, Buttons:Int):Bool
	{
		#if !FLX_NO_GAMEPAD
		var g:FlxGamepad = FlxG.gamepads.getByID(PlayerNo);
		if (g != null)
		{
			return g.anyJustPressed(buttons[PlayerNo][Buttons]);
		}
		#end
		return false;
	}
	
	public static function anyButtonPressed(PlayerNo:Int, Buttons:Int):Bool 
	{
		#if !FLX_NO_GAMEPAD
		var g:FlxGamepad = FlxG.gamepads.getByID(PlayerNo);
		if (g != null)
		{
			return g.anyPressed(buttons[PlayerNo][Buttons]);
		}
		#end
		return false;
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
	
	public static function newState():Void
	{
		canInteract = false;
	}
}
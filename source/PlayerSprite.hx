package ;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;

class PlayerSprite extends FlxSprite
{

	private static var SPEED:Int = 100;
	private static var JUMPPOWER:Int = 800;
	private static var JUMPTIME:Int = 1;
	
	public var playerNumber:Int;
	public var character:Int;
	
	private var _jumpTimer:Float;
	
	public function new(X:Float=0, Y:Float=0, PlayerNumber:Int, Character:Int) 
	{
		super(X, Y);
		playerNumber = PlayerNumber;
		character = Character;
		loadGraphic("assets/images/player-" + character + ".png", false, 20, 20);
		setFacingFlip(FlxObject.LEFT, false,false);
		setFacingFlip(FlxObject.RIGHT, true,false);
		drag.x = 800;
		acceleration.y = 1600;
		
	}
	
	override public function update():Void 
	{
		
		movement();
		
		
		super.update();
	}
	
	private function movement():Void
	{
		var _up:Bool = false;
		var _down:Bool = false;
		var _left:Bool = false;
		var _right:Bool = false;
		var _jump:Bool = false;
		
		
		GameControls.checkInputs(playerNumber);
		
		_up = GameControls.getInput(playerNumber, GameControls.PRESSED, GameControls.UP);
		_down = GameControls.getInput(playerNumber, GameControls.PRESSED, GameControls.DOWN);
		_left = GameControls.getInput(playerNumber, GameControls.PRESSED, GameControls.LEFT);
		_right = GameControls.getInput(playerNumber, GameControls.PRESSED, GameControls.RIGHT);
		_jump = GameControls.getInput(playerNumber, GameControls.PRESSED, GameControls.JUMP);
		
		if (_up && _down)
			_up = _down = false;
		if (_left && _right)
			_left = _right = false;
			
		if (_left)
		{
			facing = FlxObject.LEFT;
			velocity.x = -SPEED;
		}
		else if (_right)
		{
			facing = FlxObject.RIGHT;
			velocity.x = SPEED;
		}
		if (touching == FlxObject.FLOOR)
			_jumpTimer = 1;
		
		
		if (_jumpTimer > 0)
		{
			if (_jump)
			{
				velocity.y = -SPEED;
				if (_jumpTimer == 1)
					velocity.y *= 1.6;
			}
			else
			{
				_jumpTimer = -1;
			}
			
			_jumpTimer -= FlxG.elapsed*4;
		}
		
	}
	
}
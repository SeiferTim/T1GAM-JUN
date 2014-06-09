package ;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.util.FlxTimer;

class PlayerSprite extends FlxSprite
{

	private static var MAX_SPEED:Int = 60;
	private static var ACCELERATION:Int = 120;
	private static var DRAG:Int = 640;
	private static var JUMP_SPEED:Int = -150;
	private static var GRAVITY:Int = 1200;
	private static var JUMP_TIME:Float = 0.22;
	private static var GRAVITY_LAG:Float = .12;
	
	public var timerStarted = false;
	public var playerNumber:Int;
	public var character:Int;
	
	private var _jumpTimer:FlxTimer;
	public var _gravityLag:Float;
	public var _canJump:Bool;
	public var _hasJumped:Bool;
	
	public function new(X:Float=0, Y:Float=0, PlayerNumber:Int, Character:Int) 
	{
		super(X, Y);
		playerNumber = PlayerNumber;
		character = Character;
		loadGraphic("assets/images/player-" + character + ".png", false, 20, 20);
		setFacingFlip(FlxObject.LEFT, false,false);
		setFacingFlip(FlxObject.RIGHT, true, false);
		maxVelocity.x = MAX_SPEED;
		maxVelocity.y = MAX_SPEED * 20;
		drag.x = DRAG;
		acceleration.y = GRAVITY;
		width = 6;
		height = 16;
		offset.x = 9;
		offset.y = 4;
		
		FlxG.watch.add(this, "_canJump");
		FlxG.watch.add(this, "_gravityLag");
		FlxG.watch.add(this, "timerStarted");
		
		_jumpTimer = new FlxTimer();

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
		var onTheGround:Bool = isTouching(FlxObject.FLOOR) && !justTouched(FlxObject.FLOOR);
		
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
			offset.x = 9;
			facing = FlxObject.LEFT;
			velocity.x = -ACCELERATION;
		}
		else if (_right)
		{
			offset.x = 5;
			facing = FlxObject.RIGHT;
			velocity.x = ACCELERATION;
		}
		
		if (onTheGround)
		{
			_canJump = true;
			_hasJumped = false;
			if (timerStarted)
			{
				timerStarted = false;
				_jumpTimer.cancel();
			}
			
			_gravityLag = GRAVITY_LAG;
		}		
		else if (_gravityLag > 0 && !_hasJumped)
		{
			_gravityLag -= FlxG.elapsed;
			_canJump = true;
		}		
		
		if (_canJump && _jump)
		{
			_hasJumped = true;
			if (!timerStarted)
			{
				_jumpTimer.start(JUMP_TIME, onJumpEnd, 1);
				timerStarted = true;
			}
			velocity.y = JUMP_SPEED;
		}
		
		if (!_jump)
		{
			_canJump = false;
		}
		
	}
	
	private function onJumpEnd(timer:FlxTimer) 
	{
		_canJump = false;
		timerStarted = false;
	}
	
}
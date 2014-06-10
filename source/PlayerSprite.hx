package ;

import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.util.FlxSignal;
import flixel.util.FlxTimer;

class PlayerSprite extends FlxSprite
{

	// constant movement values
	// these are 'based on' pixels per frame * framerate.
	private static var ACCELERATION:Float =  1.76 	* 60;
	private static var GRAVITY:Float = 		  .64 	* 60;
	private static var MAX_GRAV:Float = 	 7.00	* 60;
	private static var JUMP_POWER:Float = 	-4.192 	* 60;
	private static var JUMP_MIN:Float = 	-2.31 	* 60;
	
	public var playerNumber:Int;
	public var character:Int;
	
	private var _jumpTimer:Float = 0;
	private var _landTimer:Float = 0;
	private var _ledgeBuffer:Float = 0;
	
	private var _shootTimer:Float = 0;
	private var _bullets:Array<Bullet>;
	
	public function new(X:Float=0, Y:Float=0, PlayerNumber:Int, Character:Int) 
	{
		super(X, Y);
		playerNumber = PlayerNumber;
		character = Character;
		loadGraphic("assets/images/player-" + character + ".png", false, 20, 20);
		setFacingFlip(FlxObject.LEFT, false,false);
		setFacingFlip(FlxObject.RIGHT, true, false);		
		width = 6;
		height = 16;
		offset.x = 9;
		offset.y = 4;
		_bullets = [];
		FlxG.watch.add(_bullets, "length");
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
		var _fire:Bool = false;
		var onTheGround:Bool = isTouching(FlxObject.FLOOR) && !justTouched(FlxObject.FLOOR);
		
		GameControls.checkInputs(playerNumber);
		
		_up = GameControls.getInput(playerNumber, GameControls.PRESSED, GameControls.UP);
		_down = GameControls.getInput(playerNumber, GameControls.PRESSED, GameControls.DOWN);
		_left = GameControls.getInput(playerNumber, GameControls.PRESSED, GameControls.LEFT);
		_right = GameControls.getInput(playerNumber, GameControls.PRESSED, GameControls.RIGHT);
		_jump = GameControls.getInput(playerNumber, GameControls.PRESSED, GameControls.JUMP);
		_fire = GameControls.getInput(playerNumber, GameControls.PRESSED, GameControls.FIRE);
		
		if (_up && _down)
			_up = _down = false;
		if (_left && _right)
			_left = _right = false;
		
		// HORIZONTAL MOVEMENT
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
		else if (!_left && !_right)
		{
			velocity.x = 0;
		}
		
		// JUMPING
		if (onTheGround)
		{
			if (_landTimer < 0)
			{
				_jumpTimer = 0;
			}
			else
				_landTimer -= FlxG.elapsed * 20;
			_ledgeBuffer = 1;
		}
		else
		{
			if (_ledgeBuffer < 0)
			{
				_landTimer = 1;
			}
			else
				_ledgeBuffer -= FlxG.elapsed * 10;
		}
		
		velocity.y += GRAVITY;
		if (velocity.y > MAX_GRAV)
			velocity.y = MAX_GRAV;
			
		if (_jump && _jumpTimer < 1)
		{
			_jumpTimer += FlxG.elapsed * 10;
			velocity.y = JUMP_POWER;
		}
		if (!_jump && velocity.y < JUMP_MIN)
		{
			velocity.y = 0;
		}
		else
			velocity.y < JUMP_MIN;
	
		// SHOOTING
		if (_shootTimer > 0)
			_shootTimer -= FlxG.elapsed * 10;
			
		for (i in 0..._bullets.length)
		{
			if (_bullets[i] != null)
			{
				if (!(_bullets[i].alive))
				{
					_bullets = _bullets.splice(i, 1);
				}
			}
		}

		
		if (_fire)
		{
			if (_shootTimer <= 0 && _bullets.length < 3)
			{
				_shootTimer = 1;
				_bullets.push(Reg.currentPlayState.fireBullet(x + (facing == FlxObject.LEFT ? -6 : width), y + (height / 2), 500 * (facing == FlxObject.LEFT ? -1 : 1), 0));
			}
		}
		
		
	}
	
	
}
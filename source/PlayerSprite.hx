package ;

import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxSignal;
import flixel.util.FlxTimer;

class PlayerSprite extends FlxSprite
{

	// constant movement values
	// these are 'based on' pixels per frame * framerate.
	private static var MAX_X_SPEED:Float =   1.76 	* Reg.FRAMERATE;
	private static var GRAVITY:Float = 		  .64 	* Reg.FRAMERATE;
	private static var MAX_GRAV:Float = 	 7.00	* Reg.FRAMERATE;
	private static var JUMP_POWER:Float = 	-4.192 	* Reg.FRAMERATE;
	private static var JUMP_MIN:Float = 	-2.31 	* Reg.FRAMERATE;
	private static var ACCELERATION:Float =   .4 	* Reg.FRAMERATE;
	private static var DECELERATION:Float =   .8 	* Reg.FRAMERATE;
	private static var BULLET_SPEED:Float =  5.00	* Reg.FRAMERATE;
		
	public var playerNumber:Int;
	public var character:Int;
	
	private var _jumpTimer:Float = 0;
	private var _landTimer:Float = 0;
	private var _ledgeBuffer:Float = 0;
	private var _shootTimer:Float = 0;
	private var _doubleJumpReady:Bool = false;
	private var _didDoubleJump:Bool = false;
	private var _spawningTimer:Float = 0;
	private var _ptSpawn:FlxPoint;
	
	public function new(X:Float=0, Y:Float=0, PlayerNumber:Int, Character:Int) 
	{
		super(X, Y);
		_ptSpawn = FlxPoint.get(X, Y);
		playerNumber = PlayerNumber;
		character = Character;
		loadGraphic("assets/images/player-" + character + ".png", false, 20, 20);
		setFacingFlip(FlxObject.LEFT, false,false);
		setFacingFlip(FlxObject.RIGHT, true, false);		
		width = 6;
		height = 16;
		offset.x = 9;
		offset.y = 4;
		maxVelocity.x = MAX_X_SPEED;
		health = 1;
		alive = false;
		exists = true;
		alpha = 0;
		
	}
	
	override public function update():Void 
	{
		if (!alive && exists && Reg.players[playerNumber].lives > 0)
		{
			if (_spawningTimer <= 0)
			{
				health = 1;
				_spawningTimer++;
				FlxTween.num(0, 1, .66, { ease:FlxEase.circInOut, startDelay:.66, complete:finishSpawn }, set_alpha);
			}
		}
		else if(alive)
		{
			movement();
		}
		super.update();
	}
	
	private function finishSpawn(_):Void
	{
		alive = true;
	}
	
	private function movement():Void
	{
		var _up:Bool = false;
		var _down:Bool = false;
		var _left:Bool = false;
		var _right:Bool = false;
		var _jump:Bool = false;
		var _fire:Bool = false;
		var _fireReleased:Bool = false;
		var _fireJustPressed:Bool = false;
			
		var onTheGround:Bool = isTouching(FlxObject.FLOOR) && !justTouched(FlxObject.FLOOR);
		
		GameControls.checkInputs(playerNumber);
		
		_up = GameControls.getInput(playerNumber, GameControls.PRESSED, GameControls.UP);
		_down = GameControls.getInput(playerNumber, GameControls.PRESSED, GameControls.DOWN);
		_left = GameControls.getInput(playerNumber, GameControls.PRESSED, GameControls.LEFT);
		_right = GameControls.getInput(playerNumber, GameControls.PRESSED, GameControls.RIGHT);
		_jump = GameControls.getInput(playerNumber, GameControls.PRESSED, GameControls.JUMP);
		
		_fire = GameControls.getInput(playerNumber, GameControls.PRESSED, GameControls.FIRE);
		_fireReleased = GameControls.getInput(playerNumber, GameControls.JUSTRELEASED, GameControls.FIRE);
		_fireJustPressed = GameControls.getInput(playerNumber, GameControls.JUSTPRESSED, GameControls.FIRE);
		
		
		if (_up && _down)
			_up = _down = false;
		if (_left && _right)
			_left = _right = false;
		
		maxVelocity.x = MAX_X_SPEED;
	
		// HORIZONTAL MOVEMENT
		if (_left)
		{
			if (!_fire)
			{
				facing = FlxObject.LEFT;
			}
			else if (facing == FlxObject.RIGHT)
			{
				maxVelocity.x = MAX_X_SPEED * .6;
			}
			
			velocity.x -= ACCELERATION;
			
		}
		else if (_right)
		{
			if (!_fire)
			{
				facing = FlxObject.RIGHT;
			}
			else if (facing == FlxObject.LEFT)
			{
				maxVelocity.x = MAX_X_SPEED * .6;
			}
			velocity.x += ACCELERATION;
		}
		else if (!_left && !_right)
		{
			if (velocity.x < 0)
			{
				if (velocity.x > -ACCELERATION)
					velocity.x = 0;
				else
					velocity.x += ACCELERATION;
			}
			else if (velocity.x > 0)
			{
				if (velocity.x < ACCELERATION)
					velocity.x = 0;
				else
					velocity.x -= ACCELERATION;
			}
			else
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
			_didDoubleJump = false;
			_doubleJumpReady = false;
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
		
		
		if (!_jump && !_didDoubleJump && _jumpTimer > FlxG.elapsed * 6)
		{
			_doubleJumpReady = true;
		}
			
		if (_jump && (_jumpTimer < 1 || _doubleJumpReady))
		{
			_jumpTimer += FlxG.elapsed * 7;
			if (_doubleJumpReady && !_didDoubleJump)
			{
				_didDoubleJump = true;
				_doubleJumpReady = false;
				_jumpTimer = 0;
				velocity.y = JUMP_POWER * .6;
			}
			else
				velocity.y = JUMP_POWER;
			
			
		}
		else if (!_jump)
		{
			_jumpTimer = 1;
		}
		
		if ((!_jump && velocity.y < JUMP_MIN))
		{
			velocity.y = 0;
		}
	
		// SHOOTING
		
		if (_fireReleased)
		{
			_shootTimer = 0;
		}
		
		if (_shootTimer > 0)
			_shootTimer -= FlxG.elapsed * 8;
			
		if ((_fire && _shootTimer <= 0) || _fireJustPressed)
		{
			if (Reg.currentPlayState.fireBullet(x + (facing == FlxObject.LEFT ? -6 : width), y + (height / 2), BULLET_SPEED * (facing == FlxObject.LEFT ? -1 : 1), 0, playerNumber))
				_shootTimer = 1;
		}
		
		
		
	}
	
	override function set_facing(Direction:Int):Int 
	{
		if (Direction == FlxObject.RIGHT)
		{
			offset.x = 5;
		}
		else if (Direction == FlxObject.LEFT)
		{
			offset.x = 9;
		}
		return super.set_facing(Direction);
	}
	
	override public function hurt(Damage:Float):Void 
	{
		super.hurt(Damage);
		_spawningTimer = 0;
		alpha = 0;
		velocity.x = 0;
		velocity.y = 0;
		setPosition(_ptSpawn.x, _ptSpawn.y);
		Reg.players[playerNumber].lives--;
		_jumpTimer = 0;
		_landTimer = 0;
		_ledgeBuffer = 0;
		_shootTimer = 0;
		_doubleJumpReady = false;
		_didDoubleJump = false;
		alive = false;
		exists = true;
	}
	
}
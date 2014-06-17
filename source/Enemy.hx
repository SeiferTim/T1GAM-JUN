package ;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxRandom;
import flixel.util.FlxColor;

class Enemy extends FlxSpriteGroup implements IEnemy
{
	private static var ACCELERATION:Float =   .4 	* Reg.FRAMERATE;
	private static var MAX_X_SPEED:Float =   2.00 	* Reg.FRAMERATE;
	private static var GRAVITY:Float = 		  .32 	* Reg.FRAMERATE;
	private static var MAX_GRAV:Float = 	 7.00	* Reg.FRAMERATE;
	private static var JUMP_POWER:Float = 	-3.60 	* Reg.FRAMERATE;
	
	private var _body:BossSegment;
	
	private var _hopTimer:Float;
	private var _hopDelay:Float;
	
	public function new() 
	{
		super();
		
		_body = new BossSegment(0, 0);
		_body.makeGraphic(10, 10, FlxColor.PURPLE);
		_body.hurtCallback = hurt;
		add(_body);
		maxVelocity.x = MAX_X_SPEED;
	}
	
	override public function reset(X:Float, Y:Float):Void
	{
		super.reset(X, Y);
		health = 2;
		facing = FlxRandom.chanceRoll() ? FlxObject.LEFT : FlxObject.RIGHT;
		_hopTimer = 0;
		_hopDelay = FlxRandom.int(0,6);
	}
	
	override public function update():Void
	{
		if (!alive || !exists)
			return;
		
		if (_body.justTouched(FlxObject.RIGHT))
		{
			facing = FlxObject.LEFT;
		}
		else if (_body.justTouched(FlxObject.LEFT))
		{
			facing = FlxObject.RIGHT;
		}
		
		var onGround:Bool = _body.isTouching(FlxObject.FLOOR) && !_body.justTouched(FlxObject.FLOOR);
		
		velocity.x += ACCELERATION * (facing == FlxObject.LEFT ? -1 : 1);
		
		velocity.y += GRAVITY;
		if (velocity.y > MAX_GRAV)
			velocity.y = MAX_GRAV;
			
		/*_hopTimer += FlxG.elapsed * 7;
		if (_hopTimer >= 0)// && _hopTimer < 1)
		{
			if (onGround || _hopTimer > 0)
			{
				velocity.y = JUMP_POWER;
			}
		}
		else if (_hopTimer >= 1)
		{
			_hopTimer = -3;
		}*/
		if (_hopDelay > 0)
			_hopDelay -= FlxG.elapsed * 7;
		if ((_hopTimer > 0 || (_hopTimer == 0 && onGround)) && _hopTimer < 1 && _hopDelay <= 0)
		{
			velocity.y = JUMP_POWER;
			_hopTimer += FlxG.elapsed * 7;
		}
		else if (_hopTimer >= 1)
		{
			_hopTimer = 0;
			_hopDelay = FlxRandom.int(0,6);
		}
			
		super.update();
	}
	
	override public function hurt(Damage:Float):Void 
	{
		velocity.x = 0;
		_hopTimer = -3;
		
		super.hurt(Damage);
	}
}
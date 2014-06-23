package ;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRandom;
import flixel.util.FlxColor;
import openfl.geom.ColorTransform;
using flixel.math.FlxVelocity;

class Bullet extends FlxSprite
{

	public static inline var HURTS_NONE:Int = 0x00;
	public static inline var HURTS_OPPOSITE:Int = 0x01;
	public static inline var HURTS_BULLET:Int = 0x10;
	public static inline var HURTS_ANY:Int = 0x111;
	
	
	public static inline var PLAYER_BULLET:Int = 0;
	public static inline var ENEMY_BULLET:Int = 1;
	public static inline var ENEMY_TRACKING:Int = 2;
	public static inline var ENEMY_FIRE:Int = 3;
	public static inline var EXPLOSION:Int = 4;
	
	public var style:Int = PLAYER_BULLET;
	private var _target:PlayerSprite;
	private var _turnTimer:Float = 0;
	public var hurts:Int = HURTS_NONE;
	
	
	public function fire(X:Float, Y:Float, VelocityX:Float, VelocityY:Float, Style:Int = PLAYER_BULLET, ?Target:PlayerSprite, Hurts:Int=HURTS_NONE):Void
	{
		hurts = Hurts;
		style = Style;
		drag.set();
		alpha = 1;
		switch (style) 
		{
			case PLAYER_BULLET:
				loadGraphic(AssetPaths.bullet__png, false, 6, 4);
				
			case ENEMY_BULLET:
				loadGraphic(AssetPaths.enemy_bullet__png, false, 10, 10);
				
			case ENEMY_TRACKING:
				makeGraphic(12, 12, FlxColor.MAGENTA);
				
			case ENEMY_FIRE:
				var size:Int = FlxRandom.int(2, 10);
				makeGraphic(size, size, FlxColor.ORANGE);
				health = 60;
				drag.set(20, 20);
			case EXPLOSION:
				makeGraphic(50, 50, FlxColor.YELLOW);
				health = .66;
				
		}
		_turnTimer = 0;
		reset(X-(width/2), Y-(height/2));
		setFacingFlip(FlxObject.LEFT, false, false);
		setFacingFlip(FlxObject.RIGHT, true, false);
		
		if (style != ENEMY_TRACKING)
		{
			velocity.x  = VelocityX;
			velocity.y = VelocityY;
			if (velocity.x < 0)
				facing = FlxObject.LEFT;
			else
				facing = FlxObject.RIGHT;
				
			allowCollisions = FlxObject.ANY;
		}
		else
		{
			allowCollisions = FlxObject.NONE;
			_target = Target;
			health = 200;
			velocity.x = 0;
			velocity.y = 0;
		}
	}
	
	private function pop():Void
	{
		// explode?
		var m:FlxPoint = getMidpoint();
		Reg.currentPlayState.addExplosion(m.x, m.y);
		Reg.currentPlayState.fireEnemyBullet(m.x, m.y, 0, 0, Bullet.EXPLOSION);
		kill();
	}
	
	override public function update():Void 
	{
		
		if (!alive || !exists)
			return;
		
		if (!isOnScreen() || isTouching(FlxObject.ANY))
			kill();
		
		if (style == ENEMY_TRACKING)
		{
			
			if (!_target.alive || Math.abs(FlxMath.getDistance(_target.getMidpoint(), getMidpoint())) < 16 || health <= 0)
			{
				pop();
			}
			health--;
			if (_turnTimer <=0)
			{
				moveTowardsObject(_target, 80);
				_turnTimer = 1;
			}
			else
				_turnTimer -= FlxG.elapsed * 6;
		}
		else if (style == ENEMY_FIRE)
		{
			health--;
			if (health == 40)
				drag.set(80, 80);
			else if (health <= 0)
				kill();
			if (health < 10)
			{
				alpha = health * .1 * 2;
			}
		}
		else if (style == EXPLOSION)
		{
			if (health <= 0)
				kill();
			else
				health -= FlxG.elapsed;
		}
		
			
		super.update();
	}
}
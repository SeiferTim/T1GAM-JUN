package ;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.math.FlxAngle;
import flixel.math.FlxPoint;
import flixel.math.FlxRandom;

class FlameJet extends FlxObject
{

	private var _life:Float;
	private var _base:FlxPoint;
	
	public function new(X:Float=0, Y:Float=0) 
	{
		super(X, Y, 10, 10);
		kill();
	}
	
	public function start(X:Float, Y:Float):Void
	{
		reset(X, Y);
		_life = 2;
		_base = FlxPoint.get(X, Y + 10);
		
	}
	
	
	override public function update():Void 
	{
		
		if (!alive || !exists)
			return;
		
		if (_life <= 0)
			kill();
		else
			_life-= FlxG.elapsed;
			
		var _traj:FlxPoint;
		_traj = FlxAngle.getCartesianCoords(100, FlxRandom.float(-90, -80));
		Reg.currentPlayState.fireEnemyBullet(_base.x+FlxRandom.int(1,9), _base.y, _traj.x, _traj.y, Bullet.ENEMY_FIRE);
		
		
		super.update();
	}
	
}
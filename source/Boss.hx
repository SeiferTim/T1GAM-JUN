package ;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.input.android.FlxAndroidKeyList;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class Boss extends FlxSpriteGroup
{

	private var _brain:FSM;
	private var _body:BossSegment;
	private var _head:BossSegment;
	private var _actTimer:Float = 0;
	private var _shootTimer:Float = 0;
	private var _fireAngle:Float = 0;
	
	public function new() 
	{
		super();
		
		_brain = new FSM(initialize);
		
		health = 100;
		
		_body = new BossSegment(0, 0);
		_body.makeGraphic(60, 60, FlxColor.ORANGE);
		add(_body);
		
		_head = new BossSegment(20, -20);
		_head.makeGraphic(20, 20, FlxColor.CYAN);
		_head.damageMod = 1.5;
		add(_head);
		
		FlxG.watch.add(this, "_actTimer");
		FlxG.watch.add(this, "_shootTimer");
		FlxG.watch.add(this, "_fireAngle");
		
	}
	
	
	override public function update():Void 
	{
		
		_brain.update();
		
		super.update();
	}
	
	public function initialize():Void
	{
		if (_actTimer < 1)
			_actTimer += FlxG.elapsed;
		else
			_brain.activeState = phaseOne;
	}
	
	public function phaseOne():Void
	{
		if (_shootTimer > 1)
		{
			
			_fireAngle = 45;
			var _traj:FlxPoint = FlxPoint.get(100, 0);
			_point = FlxPoint.get(0, 0);
			
			_traj.rotate(_point, -225);
			for (i in 0...7)
			{
				Reg.currentPlayState.fireEnemyBullet(_head.x + 10, _head.y + 10, _traj.x, _traj.y);
				_traj.rotate(_point, FlxAngle.wrapAngle(_fireAngle));
			}
			_traj.put();
			_shootTimer = 0;
		}
		else
		{
			_shootTimer += FlxG.elapsed * 2;
		}
	}
	
	
}
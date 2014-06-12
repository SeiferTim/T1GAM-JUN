package ;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.input.android.FlxAndroidKeyList;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class Boss extends FlxSpriteGroup
{

	private var _brain:FSM;
	private var _body:BossSegment;
	private var _head:BossSegment;
	private var _hands:Array<BossSegment>;
	private var _actTimer:Float = 0;
	private var _shootTimer:Float = 0;
	private var _fireAngle:Float = 0;
	public var vulnerable(default, null):Bool;
	private var _laughTimes:Int = 0;
	private var _laughDone:Bool = false;
	private var _doneBarFadeIn:Bool = false;
	
	public function new() 
	{
		super();
		
		vulnerable = false;
		
		_brain = new FSM(initialize);
		
		health = 0;
		
		_body = new BossSegment(0, 0);
		_body.makeGraphic(60, 60, FlxColor.ORANGE);
		add(_body);
		
		_head = new BossSegment(20, -20);
		_head.makeGraphic(20, 20, FlxColor.CYAN);
		_head.damageMod = 1.5;
		add(_head);
		
		_hands = [];
		
		_hands[0] = new BossSegment( -8, 22);
		_hands[0].makeGraphic(16, 16, FlxColor.CYAN);
		add(_hands[0]);
		
		_hands[1] = new BossSegment( 52, 22);
		_hands[1].makeGraphic(16, 16, FlxColor.CYAN);
		add(_hands[1]);

		alpha = 0;
	}
	
	
	override public function hurt(Damage:Float):Void
	{
		
		if (vulnerable)
			super.hurt(Damage);
	}
	
	override public function update():Void 
	{
		
		_brain.update();
		
		super.update();
	}
	
	public function initialize():Void
	{
		if (_actTimer < 1 && _actTimer >= 0)
		{
			_actTimer += FlxG.elapsed * 4;
		}
		else
		{
			if (_actTimer != -1)
			{
				_actTimer = -1;
				FlxTween.num(0, 1, 3, { ease:FlxEase.cubeInOut, complete:finishFadeIn }, updateAlpha);
			}
		}
		
		
			
	}
	
	public function fillBar():Void
	{
		if (_actTimer == 0)
		{
			_actTimer++;
			FlxTween.num(0, 1, .66, { ease:FlxEase.cubeInOut, complete:finishBarFadeIn }, updateBarAlpha);
		}
		else if (_actTimer == 1)
		{
			if (_doneBarFadeIn)
			{
				if (health == 0)
				{
					_actTimer++;
					FlxTween.num(0, 100, 4, { ease:FlxEase.sineInOut, complete:finishHealthFill }, updateHealth);
				}
			}
		}
		else if (_actTimer == 2)
		{
			if (_laughDone)
			{
				_actTimer++;
				var delay:FlxTimer = new FlxTimer(.66, function(_) {
					vulnerable = true;
					_brain.activeState = phaseTwo;
				});
			}
		}
	}
	
	private function updateHealth(Value:Float):Void
	{
		health = Std.int(Value);
	}
	
	private function finishHealthFill(_):Void
	{
		laugh(true);
	}
	
	private function updateBarAlpha(Value:Float):Void
	{
		Reg.currentPlayState.barBossHealth.alpha = Value;
	}
	
	private function finishBarFadeIn(_):Void
	{
		_doneBarFadeIn = true;
	}
	
	public function updateAlpha(Value:Float):Void
	{
		
		_head.alpha = _hands[0].alpha = _hands[1].alpha = _body.alpha = alpha = Value;
	}
	
	public function finishFadeIn(_):Void
	{
		_actTimer = 0;
		_brain.activeState = fillBar;
	}
	
	private function laugh(Start:Bool=false):Void
	{
		if (Start)
			_laughTimes = 0;
		FlxTween.num(_head.y, _head.y + 4, .1, { ease:FlxEase.quintInOut, type:FlxTween.PINGPONG, complete:doneLaugh}, updateHeadY);
	}
	
	private function updateHeadY(Value:Float):Void
	{
		_head.y = Value;
		
	}
	
	private function doneLaugh(T:FlxTween):Void
	{
		_laughTimes++;
		if (_laughTimes > 4)
		{
			T.cancel();
			_laughDone = true;
		}
		else
			laugh();
	}
	
	public function phaseTwo():Void
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
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
using flixel.math.FlxRandom;

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
	
	private static inline var HAND_STATIONARY:Int = 0;
	private static inline var HAND_WAVING:Int = 1;
	
	private var _handMotion:Int = 0;
	private var _handsInPos:Bool = false;
	private var _handsAngle:Array<Float>;
	private var _handsPos:Array<FlxPoint>;
	
	
	public function new() 
	{
		super();
		
		vulnerable = false;
		
		_brain = new FSM(initialize);
		
		health = 0;
		
		_body = new BossSegment(0, 0);
		_body.makeGraphic(60, 60, FlxColor.ORANGE);
		_body.hurtCallback = hurt;
		add(_body);
		
		_head = new BossSegment(20, -20);
		_head.makeGraphic(20, 20, FlxColor.CYAN);
		_head.damageMod = 1.5;
		_head.hurtCallback = hurt;
		add(_head);
		
		_hands = [];
		
		_hands[0] = new BossSegment( -8, 22);
		_hands[0].makeGraphic(16, 16, FlxColor.CYAN);
		_hands[0].hurtCallback = hurt;
		add(_hands[0]);
		
		_hands[1] = new BossSegment( 52, 22);
		_hands[1].makeGraphic(16, 16, FlxColor.CYAN);
		_hands[1].hurtCallback = hurt;
		add(_hands[1]);
		
		_handsAngle = [0, 0];
		_handsPos = [FlxPoint.get( -8, 22), FlxPoint.get(52, 22)];

		alpha = 0;
	}
	
	
	override public function hurt(Damage:Float):Void
	{
		
		if (vulnerable)
			super.hurt(Damage);
	}
	
	
	private function updateHands():Void
	{
		switch (_handMotion)
		{
			case HAND_STATIONARY:
				if (_handsInPos)
				{
					_handsInPos = false;
				}
				else
				{
					_hands[0].setPosition( _handsPos[0].x + x, _handsPos[0].y + y);
					_hands[1].setPosition( _handsPos[1].x + x, _handsPos[1].y + y);
				}
					
				
			case HAND_WAVING:
				/* */
				
		}
	}
	
	private function updateHandsX(Value:Float):Void
	{
		_hands[0].x = _handsPos[0].x + x + Value;
		_hands[1].x = _handsPos[1].x + x - Value;
	}

	private function finishHandsMoveToStart(_):Void
	{
		_handsInPos = true;
		_handsAngle[0] = 90;
		_handsAngle[1] = -90;
	}
	
	override public function update():Void 
	{
		
		_brain.update();
		updateHands();
		
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
					FlxTween.num(0, Reg.playerCount * 200, 4, { ease:FlxEase.sineInOut, complete:finishHealthFill }, updateHealth);
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
					_handMotion = HAND_WAVING;
					_actTimer = 0;
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
		//else
		//	laugh();
	}
	
	public function phaseTwo():Void
	{
		if (_shootTimer > 1)
		{
			
			if (_actTimer > 5)
			{
				_actTimer = 0;
				_shootTimer = 0;
				_brain.activeState = phaseThree;
			}
			else
			{
				_actTimer++;
				_fireAngle = 10;
				var _traj:FlxPoint = FlxPoint.get(100, 0);
				_point = FlxPoint.get(0, 0);
				
				_traj.rotate(_point, -225);
				for (i in 0...30)
				{
					Reg.currentPlayState.fireEnemyBullet(_head.x + 10, _head.y + 10, _traj.x, _traj.y);
					_traj.rotate(_point, FlxAngle.wrapAngle(_fireAngle));
				}
				_traj.put();
				_shootTimer = 0;
			}
		}
		else
		{
			_shootTimer += FlxG.elapsed * .5;
		}
	}
	
	public function phaseThree():Void
	{
		if (_actTimer > 1)
		{
			if (_shootTimer < 3)
			{
				
				Reg.currentPlayState.enemySpawns.shuffleArray(10);
				
				Reg.currentPlayState.spawnEnemy(0, Reg.currentPlayState.enemySpawns[0].x, Reg.currentPlayState.enemySpawns[0].y);
				
				if (Reg.playerCount > 1)
					Reg.currentPlayState.spawnEnemy(0, Reg.currentPlayState.enemySpawns[1].x, Reg.currentPlayState.enemySpawns[1].y);
				
				if (Reg.playerCount > 2)
					Reg.currentPlayState.spawnEnemy(0, Reg.currentPlayState.enemySpawns[2].x, Reg.currentPlayState.enemySpawns[2].y);
				
				if (Reg.playerCount > 3)
					Reg.currentPlayState.spawnEnemy(0, Reg.currentPlayState.enemySpawns[3].x, Reg.currentPlayState.enemySpawns[3].y);
				
				
				_shootTimer++;
				_actTimer = 0;
			}
			else
			{
				_shootTimer = 0;
				_actTimer = 0;
				_brain.activeState = phaseFour;
			}
		}
		else
		{
			_actTimer += FlxG.elapsed;
		}
	}
	
	public function phaseFour():Void
	{
		
	}
	
	
	
}
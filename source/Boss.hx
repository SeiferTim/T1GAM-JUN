package ;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.input.android.FlxAndroidKeyList;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRandom;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
using flixel.util.FlxArrayUtil;
using flixel.math.FlxRandom;

class Boss extends FlxSpriteGroup
{

	private var _body:BossSegment;
	private var _head:BossSegment;
	private var _hands:Array<BossSegment>;
	private var _actTimer:Float = 0;
	private var _shootTimer:Float = 0;
	//private var _fireAngle:Float = 0;
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
	
	private var _phase:Int = 0;
	//private var _phases:Array<Int>;
	
	private var _maxHealth:Int = 0;
	private var _fireAngle:Float = -400;
	private var _fireDir:Int = 1;
	
	
	public function new() 
	{
		super();
		
		vulnerable = false;
		
		//_brain = new FSM(initialize);
		
		health = 0;
		_maxHealth = 200 * Reg.playerCount;
		
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
		
		FlxG.watch.add(this, "_fireAngle");
		
		//_phases = [2, 3, 4];
		
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
		
		
		updatePhase();
		
		updateHands();
		
		super.update();
	}
	
	private function updatePhase():Void
	{
		switch (_phase) 
		{
			case 0:
				initialize();
			case 1:
				fillBar();
			case 2:
				phaseTwo();
			case 3:
				phaseThree();
			case 4:
				phaseFour();
			case 5:
				phaseFive();
				
				
		}
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
					
					FlxTween.num(0, _maxHealth, 3, { ease:FlxEase.sineInOut, complete:finishHealthFill }, updateHealth);
				}
			}
		}
		else if (_actTimer == 2)
		{
			if (_laughDone)
			{
				_actTimer++;
				Reg.currentPlayState.startMusic();
				var delay:FlxTimer = new FlxTimer(.66, function(_) {
					vulnerable = true;
					_handMotion = HAND_WAVING;
					switchPhase();
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
		_phase = 1;
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
			FlxTween.num(_head.y, _head.y - 4, .1, { ease:FlxEase.quintInOut, type:FlxTween.ONESHOT, complete:doneDoneLaugh }, updateHeadY);
		}
		//else
		//	laugh();
	}
	
	private function doneDoneLaugh(_):Void
	{
		
		_laughDone = true;
	}
	
	public function phaseTwo():Void
	{
		// circle of bullets
		if (_shootTimer > 1)
		{
			
			if (_actTimer > 5)
			{
				switchPhase();
			}
			else
			{
				_actTimer++;
				_fireAngle = 0;
				var _traj:FlxPoint = FlxPoint.get(100, 0);
				_point = FlxPoint.get(0, 0);
				
				while (_fireAngle < 360)
				{
					_traj = FlxAngle.getCartesianCoords(100, _fireAngle);
					Reg.currentPlayState.fireEnemyBullet(_head.x + 10, _head.y + 10, _traj.x, _traj.y, Bullet.ENEMY_BULLET);
					_fireAngle += 360 / 36;
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
		// small imps
		if (_actTimer > 1)
		{
			if (_shootTimer < 2 * healthRatio())
			{
				
				Reg.currentPlayState.enemySpawns.shuffleArray(10);
				
				for (i in 0...Reg.playerCount)
				{
					if (Reg.currentPlayState.playerSprites[i].alive)
						Reg.currentPlayState.spawnEnemy(0, Reg.currentPlayState.enemySpawns[i].x, Reg.currentPlayState.enemySpawns[i].y);
				}
				
				_shootTimer++;
				_actTimer = 0;
			}
			else
			{
				switchPhase();
			}
		}
		else
		{
			_actTimer += FlxG.elapsed;
		}
	}
	
	private function switchPhase():Void
	{
		_actTimer = 0;
		_shootTimer = 0;
		_fireAngle = -400;
		_fireDir = 1;
		_phase = FlxRandom.int(2, 5, [_phase]);
		
		//_phase = 
	}
	
	private function healthRatio():Int
	{
		// 1.00 = 1;
		//  .75 = 2;
		//  .50 = 3;
		//  .25 = 4;
		var h:Float = health / _maxHealth;
		if (h < .25)
			return 3;
		else if (h < .5)
			return 2;
		else
			return 1;
		
		
	}
	
	public function phaseFour():Void
	{
		// homing missles
		if (_actTimer < healthRatio())
		{
			if (_shootTimer > 1)
			{
				_actTimer++;
				_shootTimer = 0;
				
				for (i in 0...Reg.playerCount)
				{
					if (Reg.currentPlayState.playerSprites[i].alive)
						Reg.currentPlayState.fireEnemyBullet(_head.x + 10, _head.y + 10, 0, 0,Bullet.ENEMY_TRACKING, i);
				}
			}
			else
				_shootTimer += FlxG.elapsed * .33;
		}
		else
		{
			if (_shootTimer > 1)
			{
				switchPhase();
			}
			else
				_shootTimer += FlxG.elapsed * .66;
		}
	}
	
	public function phaseFive():Void
	{
		// flamethrower
		if (_fireAngle == -400)
			_fireAngle = FlxAngle.wrapAngle(140);
		
		var _times:Int = FlxRandom.int(1, 3);
		
		var _start:FlxPoint = FlxAngle.getCartesianCoords(60, _fireAngle);
		var _traj:FlxPoint;// = FlxPoint.get(0, 100);
		
		for (i in 0..._times)
		{
			_traj = FlxAngle.getCartesianCoords(100, FlxRandom.float(_fireAngle - 40, _fireAngle + 40));
			Reg.currentPlayState.fireEnemyBullet(_body.x + 30 +_start.x, _body.y + 30 + _start.y, _traj.x, _traj.y,Bullet.ENEMY_FIRE);
		}
		
		if (healthRatio() >= 2)
		{
			_times = FlxRandom.int(1, 3);
			var tmpStart:FlxPoint = FlxAngle.getCartesianCoords(60, 180 - _fireAngle);
			var tmpTraj:FlxPoint;
			
			for (i in 0..._times)
			{	
				tmpTraj = FlxAngle.getCartesianCoords(100, FlxRandom.float(180 - _fireAngle - 40, 180 - _fireAngle + 40));
				Reg.currentPlayState.fireEnemyBullet(_body.x + 30 + tmpStart.x, _body.y + 30 + tmpStart.y, tmpTraj.x, tmpTraj.y, Bullet.ENEMY_FIRE);
			}

		}
		
		_fireAngle = FlxAngle.wrapAngle(_fireAngle + (FlxG.elapsed * 40 * _fireDir));
		if ((_fireDir == 1 && _fireAngle > 40 && _fireAngle < 140) || (_fireDir == -1 && _fireAngle < 140 && _fireAngle > 40))
		{
			_shootTimer++;
			_fireDir *= -1;
		}
		if (_shootTimer >= 2)
		{
			switchPhase();
		}

		
		
	}
	
	
}
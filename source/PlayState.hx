package;

import flixel.addons.ui.FlxUICursor;
import flixel.addons.ui.FlxUIState;
import flixel.addons.ui.MultiKey;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxAngle;
import flixel.math.FlxPoint;
import flixel.math.FlxRandom;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.util.FlxSignal;
import haxe.EnumFlags;
using flixel.util.FlxArrayUtil;
using flixel.math.FlxRandom;
using flixel.util.FlxSpriteUtil;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxState
{
	
	
	private var _players:Array<Bool>;
	public var playerSprites:Array<PlayerSprite>;
	private var _room:Room;
	private var _grpPlayers:FlxTypedGroup<PlayerSprite>;
	private var _grpPlayerBullets:Array<FlxTypedGroup<Bullet>>;
	private var _boss:Boss;
	private var _playerSpawns:Array<FlxPoint>;
	public var enemySpawns:Array<FlxPoint>;
	public var barBossHealth:FlxBar;
	private var _grpEnemyBullets:FlxTypedGroup<Bullet>;
	private var _grpEnemies:FlxTypedGroup<Enemy>;
	private var _playerStats:Array<PlayerStat>;
	private var _grpHUD:FlxGroup;
	private var _grpExplosions:FlxTypedGroup<Explosion>;
	private var _grpSignals:FlxTypedGroup<Signal>;
	private var _grpFlameJets:FlxTypedGroup<FlameJet>;
	private var _stopOverlaps:Bool = false;
	private var _sprFadeOut:FlxSprite;
	private var _txtGameEnd:FlxText;
	private var _leaving:Bool = false;
	private var _gameOver:Bool = false;
	private var _btnPlayAgain:FlxButton;
	private var _btnMenu:FlxButton;
	
	
	public function new(Players:Array<Int>):Void
	{
		super();
		
		
		
		bgColor = 0xff333333;

		_players = [false, false, false, false];
		for (i in 0...4)
		{
			if (Players[i] != -1)
			{
				Reg.playerCount++;
				Reg.players[i] = new Player(i, Players[i]);
				_players[i] = true;
			}
		}
		
		
	}
	
	
	
	
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		
		_room = new Room(Reg.level);
		add(_room.bg);
		add(_room.walls);
		_grpPlayerBullets = [];
		
		playerSprites = [];
		
		_grpPlayers = new FlxTypedGroup<PlayerSprite>(4);
		
		_boss = new Boss();
		_boss.setPosition(170, 100);
		add(_boss);
		
		_grpEnemies = new FlxTypedGroup<Enemy>();
		add(_grpEnemies);
		
		_playerSpawns = _room.spawns.copy();
		_playerSpawns.shuffleArray(10);
		
		enemySpawns = _room.espawns.copy();
		
		_grpHUD = new flixel.group.FlxGroup();
		_playerStats = [];
		
		for (i in 0...4)
		{
			if (_players[i])
			{
				playerSprites[i] = new PlayerSprite(_playerSpawns[i].x + 2, _playerSpawns[i].y - 6, i, Reg.players[i].character);
				if (playerSprites[i].x < FlxG.width / 2)
					playerSprites[i].facing = FlxObject.RIGHT;
				else
					playerSprites[i].facing = FlxObject.LEFT;
				_grpPlayers.add(playerSprites[i]);
				_grpPlayerBullets[i] = new FlxTypedGroup<Bullet>(6);
				add(_grpPlayerBullets[i]);
				
				_playerStats[i] = new PlayerStat((i == 0 || i == 2 ? 5 : FlxG.width - 80), (i == 0 || i == 1 ? 5 : FlxG.height - 15), Reg.players[i].character);
				_grpHUD.add(_playerStats[i]);
				
			}
		}		
		
		
		add(_grpPlayers);
		
		_grpEnemyBullets = new FlxTypedGroup<Bullet>();
		add(_grpEnemyBullets);
		
		_grpExplosions = new FlxTypedGroup<Explosion>();
		add(_grpExplosions);
		
		barBossHealth = new FlxBar(100, 5, FlxBarFillDirection.LEFT_TO_RIGHT, FlxG.width - 200, 10, _boss, "health", 0, _boss.maxHealth, true);
		barBossHealth.alpha = 0;
		_grpHUD.add(barBossHealth);
		
		_grpSignals = new FlxTypedGroup<Signal>();
		add(_grpSignals);
		
		_grpFlameJets = new FlxTypedGroup<FlameJet>();
		add(_grpFlameJets);
		
		
		
		_sprFadeOut = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		_sprFadeOut.alpha = 0;
		_sprFadeOut.visible = false;
		add(_sprFadeOut);
		
		_txtGameEnd = new FlxText(0, 0, FlxG.width, "", 22);
		_txtGameEnd.alignment = "center";
		_txtGameEnd.y = -30;
		_txtGameEnd.alpha = 0;
		_txtGameEnd.visible = false;
		add(_txtGameEnd);
		
		add(_grpHUD);
		
		Reg.currentPlayState = this;
		
		FlxG.camera.fade(FlxColor.BLACK, .3, true, doneFadeIn);
		
		super.create();
		

		
		#if !FLX_NO_MOUSE
		FlxG.mouse.visible = false;
		#end
	}
	
	public function fireBullet(X:Float, Y:Float, VelocityX:Float, VelocityY:Float, PlayerNo:Int, BulletType:Int = Bullet.PLAYER_BULLET):Bool
	{
		if (_grpPlayerBullets[PlayerNo].countLiving() < 6)
		{
			var b:Bullet = _grpPlayerBullets[PlayerNo].recycle();
			if (b == null)
				b = new Bullet();
			b.fire(X, Y, VelocityX, VelocityY, BulletType, null, BulletType == Bullet.PLAYER_BULLET ? Bullet.HURTS_OPPOSITE : Bullet.HURTS_ANY,PlayerNo);
			_grpPlayerBullets[PlayerNo].add(b);
			return true;
		}
		return false;
		
	}
	
	public function spawnJet(X:Float, Y:Float):Void
	{
		var j:FlameJet;
		j = _grpFlameJets.recycle();
		if (j == null)
			j = new FlameJet();
			
		j.start(X, Y);
		_grpFlameJets.add(j);
	}
	
	public function addExplosion(X:Float, Y:Float):Void
	{
		var e:Explosion = _grpExplosions.recycle();
		if (e == null)
			e = new Explosion();
		e.burst(X, Y);
		_grpExplosions.add(e);
	}
	
	public function fireEnemyBullet(X:Float, Y:Float, VelocityX:Float, VelocityY:Float, BulletType:Int, PlayerTarget:Int=-1):Void
	{
		var b:Bullet = _grpEnemyBullets.recycle();
		if (b == null)
			b = new Bullet();
		if (PlayerTarget == -1)
			b.fire(X, Y, VelocityX, VelocityY, BulletType,null, Bullet.HURTS_OPPOSITE);
		else
			b.fire(X, Y, VelocityX, VelocityY, BulletType, playerSprites[PlayerTarget], Bullet.HURTS_OPPOSITE);
		_grpEnemyBullets.add(b);
	}
	
	private function doneFadeIn():Void
	{
		GameControls.canInteract = true;
	}
	
	/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		super.destroy();
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update():Void
	{	
		
		
		super.update();
		
		if (_gameOver)
		{
			return;
		}
		
		FlxG.collide(_room.walls, _grpPlayers);
		FlxG.collide(_room.walls, _grpEnemyBullets);
		FlxG.collide(_room.walls, _grpEnemies);
		FlxG.overlap(_grpPlayers, _grpPlayers, null, checkPlayerTouchesPlayer);
		
		for (i in 0...4)
		{
			if (_grpPlayerBullets[i] != null)
			{
				FlxG.collide(_room.walls, _grpPlayerBullets[i]);
				if (!_stopOverlaps)
				{
					FlxG.overlap(_grpPlayerBullets[i], _boss, bulletHitBoss);
					FlxG.overlap(_grpPlayerBullets[i], _grpEnemies, bulletHitEnemy);
					FlxG.overlap(_grpPlayerBullets[i], _grpEnemyBullets, playerBulletHitsEnemyBullet);
				}
			}
			if (_players[i])
			{
				if (!_stopOverlaps)
				{
					FlxG.overlap(_grpEnemyBullets, playerSprites[i], enemyBulletHitPlayer);
					FlxG.overlap(_grpEnemies, playerSprites[i], enemyHitPlayer);
				}
				
			}
		}
		
	}	
	
	
	
	private function checkPlayerTouchesPlayer(P1:PlayerSprite, P2:PlayerSprite):Bool
	{
		
		if (P1.alive && P1.exists && P2.alive && P2.exists)
		{
			
			//
			
			/*P1.y = P1.last.y;
			P2.y = P2.last.y;
			P1.x = P1.last.x;
			P2.x = P2.last.x;*/
			
			FlxObject.separate(P1, P2);
			var dY:Float = (Math.abs(P1.velocity.y) + Math.abs(P2.velocity.y)) * .5 * .1;
			if (dY < 200)
				dY = 200;
			if (P1.y < P2.y)
			{
				P1.velocity.y = -dY;
				P2.velocity.y = dY;
			}
			else if (P1.y > P2.y)
			{
				P1.velocity.y = dY;
				P2.velocity.y = -dY;
			}
			
			var dX:Float = (Math.abs(P1.velocity.x) + Math.abs(P2.velocity.x))  * .5 * .1;
			if (dX < 200)
				dX= 200;
			if (P1.x < P2.x)
			{
				P1.velocity.x = -dX;
				P2.velocity.x = dX;
			}
			else if (P1.x > P2.x)
			{
				P1.velocity.x = dX;
				P2.velocity.x = -dX;
			}
			
			return true;
		}
		return false;
	}
	
	private function playerBulletHitsEnemyBullet(PBullet:Bullet, EBullet:Bullet):Void
	{
		if (PBullet.alive && PBullet.exists && EBullet.alive && EBullet.exists && ((PBullet.hurts & Bullet.HURTS_BULLET) != 0 || (EBullet.hurts & Bullet.HURTS_BULLET) != 0))
		{
			PBullet.kill();
			EBullet.kill();
		}
	}
	
	private function bulletHitEnemy(Bull:Bullet, E:BossSegment):Void
	{
		if (Bull.alive && Bull.exists && E.alive && E.exists && (Bull.hurts & Bullet.HURTS_OPPOSITE) != 0)
		{
			Bull.kill();
			E.hurt(1);
			var owner:Int = Bull.owner;
			Reg.players[owner].score += 100;
			_playerStats[owner].updateScore(Reg.players[owner].score);
		}
	}
	
	private function enemyBulletHitPlayer(Bull:Bullet, Play:PlayerSprite):Void
	{
		if (Bull.alive && Bull.exists && Play.alive && Play.exists && (Bull.hurts & Bullet.HURTS_OPPOSITE) != 0)
		{
			Bull.kill();
			Play.hurt(1);
			_playerStats[Play.playerNumber].updateLives(Reg.players[Play.playerNumber].lives);
		}
	}
	
	private function enemyHitPlayer(E:BossSegment, Play:PlayerSprite)
	{
		if (E.alive && E.exists && Play.alive && Play.exists)
		{
			Play.hurt(1);
			_playerStats[Play.playerNumber].updateLives(Reg.players[Play.playerNumber].lives);
		}
	}
	
	private function bulletHitBoss(Bull:Bullet, Seg:BossSegment):Void
	{
		if (Bull.alive && Bull.exists && _boss.vulnerable && (Bull.hurts & Bullet.HURTS_OPPOSITE) != 0)
		{
			var owner:Int = Bull.owner;
			Reg.players[owner].score += 5;
			_playerStats[owner].updateScore(Reg.players[owner].score);
			
			Bull.kill();
			//_boss.hurt(1 * Seg.damageMod);
			//Seg.flash();
			Seg.hurt(1);
		}
	}
	
	public function spawnEnemy(EnemyType:Int, X:Float, Y:Float):Void
	{
		var e:Enemy;
		e = _grpEnemies.recycle();
		if (e == null)
			e = new Enemy();
		e.reset(X, Y);
		_grpEnemies.add(e);
		var _m:FlxPoint = e.getMidpoint();
		addExplosion(_m.x, _m.y);
	}

	public function startEnemySpawn(EnemyType:Int):Void
	{
		
		var spawns:Array<FlxPoint> = enemySpawns.shuffleArray(10);
		var s:Signal;
		
		//for (i in 0...Reg.playerCount)
		//{
			
			//{
				s = _grpSignals.recycle();
				if (s == null)
				{
					s = new Signal();
				}
				s.startSpawn(spawns[0], EnemyType);
				_grpSignals.add(s);
			//}
			
				//spawnEnemy(0, Reg.currentPlayState.enemySpawns[i].x, Reg.currentPlayState.enemySpawns[i].y);
				
			
		//}
	}
	
	public function triggerDeath():Void
	{
		_grpEnemies.kill();
		_grpEnemyBullets.kill();
		_grpFlameJets.kill();
		_grpSignals.kill();
		_stopOverlaps = true;
	}
	
	public function triggerWin():Void
	{
		// show some kind of victory message...
		_gameOver = true;
		for (i in 0...4)
		{
			if (_players[i])
			{
				
				Reg.players[i].score += 10000;
				_playerStats[i].updateScore(Reg.players[i].score);
			}
		}
		_txtGameEnd.text = "VICTORY!";
		_txtGameEnd.screenCenter(true, false);
		_txtGameEnd.visible = true;
		_sprFadeOut.visible = true;
		FlxTween.num(0, 1, 2, { ease:FlxEase.quintOut }, gameEndIn);
		
	}
	
	private function gameEndIn(Value:Float):Void
	{
		_txtGameEnd.alpha = Value * 2;
		_sprFadeOut.alpha = Value;
		_txtGameEnd.y = -30 + (Value * ((FlxG.height / 2) - (_txtGameEnd.height / 2) + 30));
		barBossHealth.alpha = (.5 - Value) * 2;
		
	}
	
	public function startMusic():Void
	{
		#if flash
		FlxG.sound.playMusic(AssetPaths.Boss_Music_Intro__mp3, 1, false);
		FlxG.sound.music.onComplete = function() { FlxG.sound.playMusic(AssetPaths.Boss_Music__mp3); };
		#else
		FlxG.sound.playMusic(AssetPaths.Boss_Music_Intro__ogg, 1, false);
		FlxG.sound.music.onComplete = function() { FlxG.sound.playMusic(AssetPaths.Boss_Music__ogg); };
		#end
	}
}

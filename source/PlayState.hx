package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.math.FlxRandom;
import flixel.text.FlxText;
import flixel.ui.FlxBar;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.util.FlxSignal;
import haxe.EnumFlags;
using flixel.util.FlxArrayUtil;
using flixel.math.FlxRandom;

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
		
		barBossHealth = new FlxBar(100, 5, FlxBarFillDirection.LEFT_TO_RIGHT, FlxG.width - 200, 10, _boss, "health", 0, Reg.playerCount * 200, true);
		barBossHealth.alpha = 0;
		_grpHUD.add(barBossHealth);
		
		_grpSignals = new FlxTypedGroup<Signal>();
		add(_grpSignals);
		
		_grpFlameJets = new FlxTypedGroup<FlameJet>();
		add(_grpFlameJets);
		
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
			b.fire(X, Y, VelocityX, VelocityY, BulletType, null, BulletType == Bullet.PLAYER_BULLET ? Bullet.HURTS_OPPOSITE : Bullet.HURTS_ANY);
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
		
		FlxG.collide(_room.walls, _grpPlayers);
		FlxG.collide(_room.walls, _grpEnemyBullets);
		FlxG.collide(_room.walls, _grpEnemies);
		
		for (i in 0...4)
		{
			if (_grpPlayerBullets[i] != null)
			{
				FlxG.collide(_room.walls, _grpPlayerBullets[i]);
				FlxG.overlap(_grpPlayerBullets[i], _boss, bulletHitBoss);
				FlxG.overlap(_grpPlayerBullets[i], _grpEnemies, bulletHitEnemy);
				FlxG.overlap(_grpPlayerBullets[i], _grpEnemyBullets, playerBulletHitsEnemyBullet);
			}
			if (_players[i])
			{
				FlxG.overlap(_grpEnemyBullets, playerSprites[i], enemyBulletHitPlayer);
				FlxG.overlap(_grpEnemies, playerSprites[i], enemyHitPlayer);
			}
		}
		
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
		
		for (i in 0...Reg.playerCount)
		{
			if (playerSprites[i].alive)
			{
				s = _grpSignals.recycle();
				if (s == null)
				{
					s = new Signal();
				}
				s.startSpawn(spawns[i], EnemyType);
				_grpSignals.add(s);
			}
			
				//spawnEnemy(0, Reg.currentPlayState.enemySpawns[i].x, Reg.currentPlayState.enemySpawns[i].y);
				
			
		}
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

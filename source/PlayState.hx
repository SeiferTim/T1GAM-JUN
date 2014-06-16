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
using flixel.util.FlxArrayUtil;
using flixel.math.FlxRandom;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxState
{
	
	public static inline var HURTS_NONE:Int = 0x00;
	public static inline var HURTS_PLAYER:Int = 0x01;
	public static inline var HURTS_ENEMY:Int = 0x10;
	public static inline var HURTS_ANY:Int = 0x11;
	
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
		_boss.setPosition(170, 110);
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
		
		
		add(_grpHUD);
		Reg.currentPlayState = this;
		
		FlxG.camera.fade(FlxColor.BLACK, .3, true, doneFadeIn);
		
		super.create();
		
		#if !FLX_NO_MOUSE
		FlxG.mouse.visible = false;
		#end
	}
	
	public function fireBullet(X:Float, Y:Float, VelocityX:Float, VelocityY:Float, PlayerNo:Int):Bool
	{
		if (_grpPlayerBullets[PlayerNo].countLiving() < 6)
		{
			var b:Bullet = _grpPlayerBullets[PlayerNo].recycle();
			if (b == null)
				b = new Bullet();
			b.fire(X, Y, VelocityX, VelocityY);
			_grpPlayerBullets[PlayerNo].add(b);
			return true;
		}
		return false;
		
	}
	
	public function addExplosion(X:Float, Y:Float, Hurts:Int = 0):Void
	{
		var e:Explosion = _grpExplosions.recycle();
		if (e == null)
			e = new Explosion();
		e.burst(X, Y, Hurts);
		_grpExplosions.add(e);
	}
	
	public function fireEnemyBullet(X:Float, Y:Float, VelocityX:Float, VelocityY:Float, PlayerTarget:Int=-1):Void
	{
		var b:Bullet = _grpEnemyBullets.recycle();
		if (b == null)
			b = new Bullet();
		if (PlayerTarget == -1)
			b.fire(X, Y, VelocityX, VelocityY, Bullet.ENEMY_BULLET);
		else
			b.fire(X, Y, VelocityX, VelocityY, Bullet.ENEMY_TRACKING, playerSprites[PlayerTarget]);
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
		FlxG.overlap(_boss, _grpExplosions, explosionHitsBoss);
		FlxG.overlap(_grpEnemies, _grpExplosions, explosionHitsEnemy);
		for (i in 0...4)
		{
			if (_grpPlayerBullets[i] != null)
			{
				FlxG.collide(_room.walls, _grpPlayerBullets[i]);
				FlxG.overlap(_grpPlayerBullets[i], _boss, bulletHitBoss);
				FlxG.overlap(_grpPlayerBullets[i], _grpEnemies, bulletHitEnemy);
			}
			if (_players[i])
			{
				FlxG.overlap(_grpEnemyBullets, playerSprites[i], enemyBulletHitPlayer);
				FlxG.overlap(_grpEnemies, playerSprites[i], enemyHitPlayer);
				FlxG.overlap(playerSprites[i], _grpExplosions, explosionHitsPlayer);
			}
		}
		
	}	
	
	private function explosionHitsBoss(B:BossSegment, E:ExplosionCloud):Void
	{
		if (B.alive && B.exists && _boss.vulnerable && E.alive && E.exists && E.parent.hurts == HURTS_ENEMY)
		{
			B.hurt(1);
		}
	}
	
	private function explosionHitsEnemy(B:BossSegment, E:ExplosionCloud):Void
	{
		if (B.alive && B.exists && E.alive && E.exists && E.parent.hurts == HURTS_ENEMY)
		{
			B.hurt(1);
		}
	}
	
	private function explosionHitsPlayer(P:PlayerSprite, E:ExplosionCloud):Void
	{
		if (P.alive && P.exists && E.alive && E.exists && E.parent.hurts == HURTS_ENEMY)
		{
			P.hurt(1);
			_playerStats[P.playerNumber].updateLives(Reg.players[P.playerNumber].lives);
		}
	}
	
	private function bulletHitEnemy(Bull:Bullet, E:BossSegment):Void
	{
		if (Bull.alive && Bull.exists && E.alive && E.exists)
		{
			Bull.kill();
			E.hurt(1);
		}
	}
	
	private function enemyBulletHitPlayer(Bull:Bullet, Play:PlayerSprite):Void
	{
		if (Bull.alive && Bull.exists && Play.alive && Play.exists)
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
		if (Bull.alive && Bull.exists && _boss.vulnerable)
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
		e = new Enemy();
		e.reset(X, Y);
		_grpEnemies.add(e);
		var _m:FlxPoint = e.getMidpoint();
		addExplosion(_m.x, _m.y, HURTS_NONE);
	}
}

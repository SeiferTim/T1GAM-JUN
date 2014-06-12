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
	
	private var _players:Array<Bool>;
	private var _playerSprites:Array<PlayerSprite>;
	private var _room:Room;
	private var _grpPlayers:FlxTypedGroup<PlayerSprite>;
	private var _grpPlayerBullets:Array<FlxTypedGroup<Bullet>>;
	private var _boss:Boss;
	private var _playerSpawns:Array<FlxPoint>;
	public var barBossHealth:FlxBar;
	private var _grpEnemyBullets:FlxTypedGroup<Bullet>;
		
	public function new(Players:Array<Int>):Void
	{
		super();
		
		bgColor = FlxColor.GRAY;
		
		_players = [false, false, false, false];
		for (i in 0...4)
		{
			if (Players[i] != -1)
			{
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
		
		_playerSprites = [];
		
		_grpPlayers = new FlxTypedGroup<PlayerSprite>(4);
		
		_boss = new Boss();
		_boss.setPosition(170, 110);
		add(_boss);
		
		_playerSpawns = _room.spawns.copy();
		_playerSpawns.shuffleArray(10);
		
		for (i in 0...4)
		{
			if (_players[i])
			{
				_playerSprites[i] = new PlayerSprite(_playerSpawns[i].x - 10, _playerSpawns[i].y -10, i, Reg.players[i].character);
				if (_playerSprites[i].x < FlxG.width / 2)
					_playerSprites[i].facing = FlxObject.RIGHT;
				else
					_playerSprites[i].facing = FlxObject.LEFT;
				_grpPlayers.add(_playerSprites[i]);
				_grpPlayerBullets[i] = new FlxTypedGroup<Bullet>(6);
				add(_grpPlayerBullets[i]);
			}
		}		
		
		
		add(_grpPlayers);
		
		_grpEnemyBullets = new FlxTypedGroup<Bullet>();
		add(_grpEnemyBullets);
		
		barBossHealth = new FlxBar(10, 5, FlxBarFillDirection.LEFT_TO_RIGHT, FlxG.width - 20, 10, _boss, "health", 0, 100, true);
		barBossHealth.alpha = 0;
		add(barBossHealth);
		
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
	
	public function fireEnemyBullet(X:Float, Y:Float, VelocityX:Float, VelocityY:Float):Void
	{
		var b:Bullet = _grpEnemyBullets.recycle();
		if (b == null)
			b = new Bullet();
		b.fire(X, Y, VelocityX, VelocityY, Bullet.ENEMY_BULLET);
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
		for (i in 0...4)
		{
			if (_grpPlayerBullets[i] != null)
			{
				FlxG.collide(_room.walls, _grpPlayerBullets[i]);
				FlxG.overlap(_grpPlayerBullets[i], _boss, bulletHitBoss);
			}
			if (_players[i])
			{
				FlxG.overlap(_grpEnemyBullets, _playerSprites[i], enemyBulletHitPlayer);
			}
		}
		
	}	
	
	private function enemyBulletHitPlayer(Bull:Bullet, Play:PlayerSprite):Void
	{
		if (Bull.alive && Bull.exists)
		{
			Bull.kill();
		}
	}
	
	private function bulletHitBoss(Bull:Bullet, Seg:BossSegment):Void
	{
		if (Bull.alive && Bull.exists && _boss.vulnerable)
		{
			Bull.kill();
			_boss.hurt(1 * Seg.damageMod);
			Seg.flash();
		}
	}
}

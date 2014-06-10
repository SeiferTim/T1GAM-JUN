package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.math.FlxRandom;
import flixel.text.FlxText;
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
	private var _grpPlayerBullets:FlxTypedGroup<Bullet>;
		
	public function new(Players:Array<Int>):Void
	{
		super();
		
		bgColor = FlxColor.CHARCOAL;
		
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
		_grpPlayerBullets = new FlxTypedGroup<Bullet>();
		
		add(_grpPlayerBullets);
		
		_playerSprites = [];
		
		_grpPlayers = new FlxTypedGroup<PlayerSprite>(4);
		add(_grpPlayers);
		
		var _spawns:Array<FlxPoint> = _room.spawns.copy();
		_spawns.shuffleArray(10);
		
		for (i in 0...4)
		{
			if (_players[i])
			{
				_playerSprites[i] = new PlayerSprite(_spawns[i].x -10, _spawns[i].y -10, i, Reg.players[i].character);
				_grpPlayers.add(_playerSprites[i]);
			}
		}		
		
		Reg.currentPlayState = this;
		
		FlxG.camera.fade(FlxColor.BLACK, .3, true, doneFadeIn);
		
		super.create();
	}
	
	public function fireBullet(X:Float, Y:Float, VelocityX:Float, VelocityY:Float):Bullet
	{
		var b:Bullet = _grpPlayerBullets.recycle();
		if (b == null)
			b = new Bullet();
		b.fire(X, Y, VelocityX, VelocityY);
		_grpPlayerBullets.add(b);
		return b;
		
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
		//FlxG.collide(_room.walls, _grpPlayerBullets);
	}	
}

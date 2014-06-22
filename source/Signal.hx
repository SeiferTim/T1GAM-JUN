package ;

import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
using flixel.util.FlxSpriteUtil;

class Signal extends FlxSprite
{

	private var _spawnPoint:FlxPoint;
	private var _eType:Int;
	
	public function new() 
	{
		super(0, 0);
		loadGraphic(AssetPaths.signal__png, false, 6, 12);
		kill();
	}
	public function startSpawn(SpawnPoint:FlxPoint, EnemyType:Int):Void
	{
		_spawnPoint = FlxPoint.get(SpawnPoint.x, SpawnPoint.y);
		_eType = EnemyType;
		reset(_spawnPoint.x + 2, _spawnPoint.y - 8);
		alpha = 1;
		flicker(1, .2, false, false, doneFlicker);
		
	}
	
	
	private function doneFlicker(_):Void
	{
		switch (_eType)
		{
			case 0:
				Reg.currentPlayState.spawnEnemy(_eType, _spawnPoint.x, _spawnPoint.y);

			case 1:
				Reg.currentPlayState.spawnJet(_spawnPoint.x, _spawnPoint.y);

		}
		
		kill();
	}
	
	override public function update():Void 
	{
			
		super.update();
	}
	
	
	
}
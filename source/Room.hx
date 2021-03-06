package ;
import flixel.addons.editors.ogmo.FlxOgmoLoader;
import flixel.FlxObject;
import flixel.math.FlxPoint;
import flixel.tile.FlxTilemap;

class Room
{
	
	private var _map:FlxOgmoLoader;
	public var bg:FlxTilemap;
	public var walls:FlxTilemap;
	public var spawns:Array<FlxPoint>;
	public var espawns:Array<FlxPoint>;
	
	public function new(RoomNo:Int)
	{
		_map = new FlxOgmoLoader("data/level-" + RoomNo + ".oel");
		
		bg = _map.loadTilemap(AssetPaths.tiles__png, 10, 10, "Background");
		walls = _map.loadTilemap(AssetPaths.tiles__png, 10, 10, "Walls");
		walls.setTileProperties(2, FlxObject.CEILING);
		
		spawns = [];
		espawns = [];
		_map.loadEntities(loadSpawn, "PlayerSpawns");
		
	}
	
	private function loadSpawn(EntityType:String, Data:Xml):Void
	{
		switch (EntityType)
		{
			case "PlayerStart":
				spawns.push(FlxPoint.get(Std.parseFloat(Data.get("x")), Std.parseFloat(Data.get("y"))));
			case "EnemySpawn":
				espawns.push(FlxPoint.get(Std.parseFloat(Data.get("x")), Std.parseFloat(Data.get("y"))));
		}
		
	}
	
}
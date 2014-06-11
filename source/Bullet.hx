package ;
import flixel.FlxObject;
import flixel.FlxSprite;


class Bullet extends FlxSprite
{

	public static inline var PLAYER_BULLET:Int = 0;
	public static inline var ENEMY_BULLET:Int = 1;
	
	public var style:Int = PLAYER_BULLET;
	
	public function fire(X:Float, Y:Float, VelocityX:Float, VelocityY:Float, Style:Int = PLAYER_BULLET):Void
	{
		style = Style;
		switch (style) 
		{
			case PLAYER_BULLET:
				loadGraphic(AssetPaths.bullet__png, false, 6, 4);
			case ENEMY_BULLET:
				loadGraphic(AssetPaths.enemy_bullet__png, false, 10, 10);
		}
		
		reset(X-(width/2), Y-(height/2));
		setFacingFlip(FlxObject.LEFT, false, false);
		setFacingFlip(FlxObject.RIGHT, true, false);
		velocity.x  = VelocityX;
		velocity.y = VelocityY;
		if (velocity.x < 0)
			facing = FlxObject.LEFT;
		else
			facing = FlxObject.RIGHT;
	}
	
	override public function update():Void 
	{
		
		if (!alive || !exists)
			return;
		
		if (!isOnScreen() || isTouching(FlxObject.ANY))
			kill();
		
		super.update();
	}
}
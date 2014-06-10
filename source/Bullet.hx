package ;
import flixel.FlxObject;
import flixel.FlxSprite;


class Bullet extends FlxSprite
{

	public function fire(X:Float, Y:Float, VelocityX:Float, VelocityY:Float):Void
	{
		loadGraphic(AssetPaths.bullet__png, false, 6, 4);
		reset(X, Y);
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
		
		if (!isOnScreen())
			kill();
		
		super.update();
	}
}
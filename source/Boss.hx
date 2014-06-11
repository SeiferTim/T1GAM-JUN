package ;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxColor;

class Boss extends FlxSpriteGroup
{

	private var _body:FlxSprite;
	
	public function new() 
	{
		super();
		_body = new FlxSprite(0, 0).makeGraphic(60, 60, FlxColor.ORANGE);
		add(_body);
		
	}
	
}
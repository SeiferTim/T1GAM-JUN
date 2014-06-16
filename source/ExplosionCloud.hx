package ;

import flixel.FlxSprite;

class ExplosionCloud extends FlxSprite
{

	public var parent(default, null):Explosion;	
	
	public function new(Parent:Explosion) 
	{
		super(0,0);
		parent = Parent;
	}
}
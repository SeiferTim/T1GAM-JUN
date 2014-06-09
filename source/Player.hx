package ;

class Player
{

	public var position(default, null):Int;
	public var character(default, null):Int;
	
	public var score:Int;
	public var health:Int;
	public var maxHealth:Int;
	
	public function new(Position:Int, Character:Int) 
	{
		position = Position;
		character = Character;
		score = 0;
		health = maxHealth = 5;
	}
	
}

enum Characters {
	RED;
	YELLOW;
	GREEN;
	//CYAN;
	BLUE;
	//MAGENTA;
}
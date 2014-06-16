package ;

class Player
{

	public var position(default, null):Int;
	public var character(default, null):Int;
	
	public var score:Int;
	public var lives:Int;
	
	public function new(Position:Int, Character:Int) 
	{
		position = Position;
		character = Character;
		score = 0;
		lives = 5;
	}
	
}

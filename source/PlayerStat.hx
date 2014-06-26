package ;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class PlayerStat extends FlxGroup
{

	private var _character:Int;
	private var _portrait:FlxSprite;
	private var _lives:Array<FlxSprite>;
	private var _x:Float;
	private var _y:Float;
	private var _width:Float;
	private var _score:FlxText;
	
	// score?
	
	public function new(X:Float, Y:Float, PlayerCharacter:Int) 
	{
		super();
		
		_character = PlayerCharacter;
		
		_x = X;
		_y = Y;
		
		_width = 75;

		var _portX:Float;
		var _livesX:Float;
		
		if (_x < FlxG.width / 2)
		{
			_portX = 0;
			_livesX = 15;
		}
		else
		{
			_livesX = 0;
			_portX = 65;
		}
		
		_portrait = new FlxSprite(_x+_portX, _y);
		switch (_character) 
		{
			case 0:
				_portrait.makeGraphic(10, 10, FlxColor.RED);
			case 1:
				_portrait.makeGraphic(10, 10, FlxColor.YELLOW);
			case 2:
				_portrait.makeGraphic(10, 10, FlxColor.GREEN);
			case 3:
				_portrait.makeGraphic(10, 10, FlxColor.BLUE);
		}
		_portrait.scrollFactor.set();
		add(_portrait);
		
		var _live:FlxSprite;
		_lives = [];
		for (i in 0...5)
		{
			_live = new FlxSprite(_x+_livesX + (12 * i), _y);
			_live.makeGraphic(10, 10, FlxColor.WHITE);
			_live.scrollFactor.set();
			_lives.push(_live);
			add(_live);
		}
		
		_score = new FlxText(_x, _y + (_y > FlxG.height / 2 ? -12 : 12), _width, "000000", 8);
		if (_x > FlxG.width / 2)
		{
			_score.x = _x + _width - _score.width;
			_score.alignment = "right";
		}
		add(_score);
	}
	
	public function updateScore(Value:Int):Void
	{
		_score.text = StringTools.lpad(Std.string(Value), "0", 6);
	}
	
	public function updateLives(Value:Int):Void
	{
		for (i in 0...5)
		{
			_lives[i].visible = i < Value;
		}
	}
	
}
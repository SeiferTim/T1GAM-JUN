package ;

import flixel.addons.ui.FlxUIState;
import flixel.FlxG;

class NewGameState extends FlxUIState
{

	private var _players:Array<Bool>;
	
	private var _charWheels:Array<CharSelectWheel>;
	
	override public function create():Void
	{
		GameControls.init();
		
		_xml_id = "state_newgame";
		
		_players = [false, false, false, false];
		
		_charWheels = [];
		for (i in 0...4)
		{
			_charWheels.push(new CharSelectWheel(16 + (i * 96), 10));
			add(_charWheels[i]);
		}
		
		
		FlxG.watch.add(this, "_players");
		
		super.create();
	}
	
	override public function update():Void 
	{
		for (i in 0...3)
		{
			if (_players[i])
			{
				if (GameControls.anyKeyJustReleased(i, GameControls.BACK))
				{
					_players[i] = false;
					_charWheels[i].deactivate();
				}
				else if (GameControls.anyKeyJustReleased(i, GameControls.SELRIGHT))
				{
					_charWheels[i].nextChar();
				}
				else if (GameControls.anyKeyJustReleased(i, GameControls.SELLEFT))
				{
					_charWheels[i].prevChar();
				}
			}
			else
			{
				if (GameControls.anyKeyJustReleased(i, GameControls.ANY))
				{
					_players[i] = true;
					_charWheels[i].activate();
				}
			}
			
		}

		super.update();
	}
	
}
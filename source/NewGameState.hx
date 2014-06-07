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
					if (_charWheels[i].locked)
					{
						_charWheels[i].unlock();
					}
					else
					{
						_players[i] = false;
						_charWheels[i].deactivate();
					}
				}
				else if (GameControls.anyKeyJustReleased(i, GameControls.SELRIGHT))
				{
					_charWheels[i].nextChar();
				}
				else if (GameControls.anyKeyJustReleased(i, GameControls.SELLEFT))
				{
					_charWheels[i].prevChar();
				}
				else if (GameControls.anyKeyJustReleased(i, GameControls.SELECT))
				{
					_charWheels[i].lock();
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
			
			if ((!_players[0] || _charWheels[0].locked) && (!_players[1] || _charWheels[1].locked) && (!_players[2] || _charWheels[2].locked) && (!_players[3] || _charWheels[3].locked) )
			{
				
			}
		}

		super.update();
	}
	
}
package ;

import flixel.addons.ui.FlxUIState;
import flixel.FlxG;

class NewGameState extends FlxUIState
{

	private var _players:Array<Bool>;
	
	override public function create():Void
	{
		GameControls.init();
		
		_xml_id = "state_newgame";
		
		_players = [false, false, false, false];
		
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
				}
			}
			else
			{
				if (GameControls.anyKeyJustReleased(i, GameControls.ANY))
				{
					_players[i] = true;
				}
			}
			
		}

		super.update();
	}
	
}
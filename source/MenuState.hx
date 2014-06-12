package;

import flixel.addons.ui.FlxUICursor;
import flixel.addons.ui.FlxUIState;
import flixel.addons.ui.MultiKey;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;

/**
 * A FlxState which can be used for the game's menu.
 */
class MenuState extends FlxUIState
{
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		
		#if !FLX_NO_MOUSE
		FlxG.mouse.visible = true;
		#end
		
		_xml_id = "state_menu";
		
		cursor = new FlxUICursor(onCursorEvent, FlxUICursor.INPUT_KEYS | FlxUICursor.INPUT_GAMEPAD, FlxUICursor.KEYS_DEFAULT_ARROWS | FlxUICursor.KEYS_DEFAULT_TAB | FlxUICursor.KEYS_DEFAULT_WASD);
		cursor.keysClick.push(new MultiKey(FlxG.keys.getKeyCode("X")));
		cursor.keysClick.push(new MultiKey(FlxG.keys.getKeyCode("C")));
		cursor.keysClick.push(new MultiKey(FlxG.keys.getKeyCode("P")));
		super.create();
		
	}
	
	
	override public function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>):Void 
	{
		var str:String = "";
		switch(id) 
		{
			case "click_button":
				if (params != null && params.length > 0)
				{
					switch(cast(params[0], String))
					{
						case "button_play":
							FlxG.switchState(new NewGameState());
					}
				}
		}
	}
	
	/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		
		super.destroy();
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update():Void
	{
		super.update();
	}	
}
package ;

import flixel.addons.ui.FlxUIState;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
using flixel.util.FlxSpriteUtil;

class NewGameState extends FlxUIState
{

	private var _players:Array<Bool>;
	
	private var _charWheels:Array<CharSelectWheel>;
	private var _delays:Array<Float>;
	private var _leaving:Bool = false;
	private var _readyTimer:Float = 3;
	private var _showingTimer:Bool = false;
	private var _txtTimer:FlxText;
	
	
	override public function create():Void
	{
		GameControls.init();
		
		//FlxG.watch.add(FlxG, "gamepads");
		FlxG.watch.add(FlxG.gamepads, "numActiveGamepads");
		
		_xml_id = "state_newgame";
		
		_players = [false, false, false, false];
		
		_delays = [0, 0, 0, 0];
		_charWheels = [];
		for (i in 0...4)
		{
			_charWheels.push(new CharSelectWheel(16 + (i * 96), 10));
			add(_charWheels[i]);
		}
		
		_txtTimer = new FlxText(0, 0, 200, "Starting in 3", 22);
		_txtTimer.alignment = "center";
		_txtTimer.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 1, 1);
		_txtTimer.y = FlxG.height - _txtTimer.height - 8;
		_txtTimer.screenCenter(true, false);
		_txtTimer.alpha = 0;
		add(_txtTimer);
		
		FlxG.camera.fade(FlxColor.BLACK, .3, true, doneFadeIn);
		
		super.create();
		
		#if !FLX_NO_MOUSE
		FlxG.mouse.visible = false;
		#end
	}
	
	private function doneFadeIn():Void
	{
		GameControls.canInteract = true;
	}
	
	override public function update():Void 
	{
		if (_leaving)
		{
			super.update();
			return;
		}
		
		for (i in 0...4)
		{
			GameControls.checkInputs(i);
			if (_players[i])
			{
				if (GameControls.getInput(i, GameControls.JUSTRELEASED, GameControls.BACK))
				{
					if (_charWheels[i].locked)
					{
						_charWheels[i].unlock();
						for (j in 0...4)
						{
							if (j != i)
							{
								_charWheels[j].unavailable[_charWheels[i].selectedItem] = false;
							}
						}
					}
					else
					{
						_players[i] = false;
						_charWheels[i].deactivate();
					}
				}
				else if (GameControls.getInput(i, GameControls.PRESSED, GameControls.SELRIGHT))
				{
					if (_delays[i] <= 0)
					{
						_charWheels[i].nextChar();
						_delays[i] = FlxG.elapsed;
					}
				}
				else if (GameControls.getInput(i, GameControls.PRESSED, GameControls.SELLEFT))
				{
					if (_delays[i] <= 0)
					{
						_charWheels[i].prevChar();
						_delays[i] = FlxG.elapsed;
					}
				}
				else if (GameControls.getInput(i, GameControls.PRESSED, GameControls.SELECT))
				{
					if (_delays[i] <= 0)
					{
						
						if (_charWheels[i].lock())
						{
							_delays[i] = FlxG.elapsed;
							for (j in 0...4)
							{
								if (j != i)
								{
									_charWheels[j].unavailable[_charWheels[i].selectedItem] = true;
								}
							}
						}
					}
				}
			}
			else
			{
				if (GameControls.getInput(i, GameControls.PRESSED, GameControls.ANY))
				{
					_players[i] = true;
					_charWheels[i].activate();
				}
			}
			_delays[i] -= FlxG.elapsed;
		}
		
		if ((_players[0] || _players[1] || _players[2] || _players[3]) && (!_players[0] || _charWheels[0].locked) && (!_players[1] || _charWheels[1].locked) && (!_players[2] || _charWheels[2].locked) && (!_players[3] || _charWheels[3].locked) )
		{
			if (!_showingTimer)
			{
				_showingTimer = true;
				FlxTween.num(0, 1, .33, { ease:FlxEase.circInOut }, updateTimerAlpha);
			}
			
			_txtTimer.text = "Starting in " + Math.ceil(_readyTimer);
			
			if (_readyTimer <= 0)
			{
				FlxG.camera.fade(FlxColor.BLACK, .33, false, function() { 
						_leaving = true;
						FlxG.switchState(new PlayState([_players[0] ? _charWheels[0].selectedItem : -1, _players[1] ? _charWheels[1].selectedItem : -1, _players[2] ? _charWheels[2].selectedItem : -1, _players[3] ? _charWheels[3].selectedItem : -1])); 
				});
			}
			else
				_readyTimer -= FlxG.elapsed;
		}
		else if (!_leaving)
		{
			if (_showingTimer)
			{
				
				FlxTween.num(1, 0, .33, { ease:FlxEase.circInOut, complete: doneTimerFadeOut }, updateTimerAlpha);
			}
			
		}
		
		super.update();
	}
	
	private function updateTimerAlpha(Value:Float):Void
	{
		_txtTimer.alpha = Value;
	}
	
	private function doneTimerFadeOut(_):Void
	{
		_showingTimer = false;
		_readyTimer = 3;
		
	}
	
}
package ;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.math.FlxRect;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import openfl.geom.Point;
import openfl.geom.Rectangle;

class CharSelectWheel extends FlxTypedSpriteGroup<FlxSprite>
{

	private var _sprDisabled:FlxSprite;
	private var _sprWheel:FlxSprite;
	private var _sprDisplay:FlxSprite;
	private var _txtPressKey:FlxText;
	public var selectedItem(default, null):Int = -1;
	private var _sliding:Bool = false;
	private var _slideY:Float = 0;
	private var _activated:Bool = false;
	private var _txtReady:FlxText;
	public var locked:Bool = false;
	public var unavailable:Array<Bool>;
	private var _sprLockOut:FlxSprite;
	
	
	public function new(X:Int, Y:Int) 
	{
		super(X,Y);
		_sprDisabled = new FlxSprite(0, 0, AssetPaths.char_select_wheel_disabled__png);
		_sprWheel = new FlxSprite(0, 0, AssetPaths.char_select_wheel__png);
	
		_sprDisplay = new FlxSprite(0, 0).makeGraphic(80, 200, FlxColor.BLACK, true);
		_sprDisplay.pixels.copyPixels(_sprDisabled.pixels, _sprDisabled.pixels.rect, _sprDisplay._flashPointZero);
		_sprDisplay.dirty = true;
		add(_sprDisplay);
		
		_sprLockOut = new FlxSprite(0, 0).makeGraphic(80, 200, FlxColor.GRAY);
		_sprLockOut.alpha = 0;
		add(_sprLockOut);
		
		_txtPressKey = new FlxText(0, 0, 80, "Join", 22);
		_txtPressKey.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 1, 1);
		_txtPressKey.alignment = "center";
		_txtPressKey.x = 40 - (_txtPressKey.width / 2);
		_txtPressKey.y = 100 - (_txtPressKey.height / 2);
		_txtPressKey.angle = -4;
		add(_txtPressKey);
		
		_txtReady = new FlxText(0, 0, 80, "Ready!", 18);
		_txtReady.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 1, 1);
		_txtReady.alignment = "center";
		_txtReady.x = 40 - (_txtReady.width / 2);
		_txtReady.y = 100 - (_txtReady.height / 2);
		add(_txtReady);
		_txtReady.visible = false;
		_txtReady.active = false;
		
		unavailable = [false, false, false, false];
		
		selectedItem = -1;
		_activated = false;
	}
	
	public function unlock():Void
	{
		locked = false;
		FlxTween.num(1, 0, .6, {ease: FlxEase.circOut}, updateReadyFade);
		
	}
	
	public function lock():Bool
	{
		if (locked || !_activated)
			return false;
		if (unavailable[selectedItem])
		{
			// do something?
			return false;
		}
		_txtReady.visible = true;
		_txtReady.active = true;
		locked = true;
		FlxTween.num(0, 1, .6, {ease: FlxEase.circOut}, updateReadyFade);
		return true;
	}
	
	override public function update():Void 
	{
		
		if (unavailable[selectedItem] && _sprLockOut.alpha == 0)
		{
			showLockOut();
			
		}
		else if (!unavailable[selectedItem] && _sprLockOut.alpha == .8)
		{
			hideLockOut();
		}
		
		super.update();
	}
	
	private function showLockOut():Void
	{
		FlxTween.num(0, .8, .2, { ease:FlxEase.circInOut }, _sprLockOut.set_alpha);
	}
	
	private function hideLockOut():Void
	{
		FlxTween.num(.8, 0, .2, { ease:FlxEase.circInOut }, _sprLockOut.set_alpha);
	}
	
	
	private function updateReadyFade(Value:Float):Void
	{
		_txtReady.alpha = Value;
		_txtReady.scale.set(2 - Value, 2 - Value);
	}
	
	public function activate():Void
	{
		if (locked || _sliding || _activated)
			return;
		nextChar();
		FlxTween.num(1, 0, .6, { ease:FlxEase.circOut, complete:donePressFadeOut }, updatePressFade);
	}
	
	private function updatePressFade(Value:Float):Void
	{
		_txtPressKey.alpha = Value;
		_txtPressKey.scale.set(2 - Value,  2 - Value);
	}
	
	private function donePressFadeIn(_):Void
	{
		_txtPressKey.alpha = 1;
		_txtPressKey.scale.set(1,  1);
	}
	
	private function donePressFadeOut(_):Void
	{
		_txtPressKey.alpha = 0;
		_txtPressKey.visible = false;
		_txtPressKey.active = false;
	}
	
	public function deactivate():Void
	{
		if (locked || _sliding || !_activated)
			return;
		_activated = false;
		prevChar();
		_txtPressKey.visible = true;
		_txtPressKey.active = true;
		FlxTween.num(0, 1, .6, { ease:FlxEase.circOut, complete:donePressFadeIn }, updatePressFade);
	}
	
	public function nextChar():Void
	{
		if (locked || _sliding)
			return;
		_sliding = true;
		
		_slideY = 200;
		FlxTween.num(_slideY, 0, .6, { ease:FlxEase.bounceOut, complete:doneSlideNext }, updateSlideNext);
	}
	
	
	public function prevChar():Void
	{
		if (locked || _sliding)
			return;
		_sliding = true;
		
		_slideY = 0;
		FlxTween.num(_slideY, 200, .6, { ease:FlxEase.bounceOut, complete:doneSlidePrev }, updateSlidePrev);
	}
	
	private function updateSlidePrev(Value:Float):Void
	{
		_slideY = Value;
		
		var _sr1:Rectangle = new Rectangle(0, ((!_activated ? 0 : ((selectedItem == 0 ? 4 : selectedItem)-1)) * 200) + 200 - _slideY, 80, _slideY-1);
		var _sr2:Rectangle = new Rectangle(0,  selectedItem * 200, 80, 200 - _slideY );
		var _dp1:Point = new Point(0, 0);
		var _dp2:Point = new Point(0, _slideY + 1);

		
		_sprDisplay.pixels.fillRect(_sprDisplay.pixels.rect, FlxColor.BLACK);
		_sprDisplay.pixels.copyPixels((selectedItem == -1 || !_activated ? _sprDisabled.pixels : _sprWheel.pixels), _sr1, _dp1);
		_sprDisplay.pixels.copyPixels(_sprWheel.pixels, _sr2, _dp2);
		_sprDisplay.dirty = true;
		
	}
	
	private function updateSlideNext(Value:Float):Void
	{
		_slideY = Value;
		
		var _sr1:Rectangle = new Rectangle(0, (((selectedItem == -1 || !_activated ? 0 : selectedItem) + 1) * 200) - _slideY, 80, _slideY-1);
		var _sr2:Rectangle = new Rectangle(0, ((selectedItem == 3 ? -1 : selectedItem) + 1) * 200 , 80, 200 - _slideY);
		var _dp1:Point = new Point(0, 0);
		var _dp2:Point = new Point(0, _slideY+1);
		
		_sprDisplay.pixels.fillRect(_sprDisplay.pixels.rect, FlxColor.BLACK);
		_sprDisplay.pixels.copyPixels((selectedItem == -1 || !_activated ? _sprDisabled.pixels : _sprWheel.pixels), _sr1, _dp1);
		_sprDisplay.pixels.copyPixels(_sprWheel.pixels, _sr2, _dp2);
		
		_sprDisplay.dirty = true;
		
	}
	
	private function doneSlideNext(_):Void
	{
		if (selectedItem == 3)
			selectedItem = 0;
		else
			selectedItem++;
			
		_activated = true;
		
		_sliding = false;
	}
	
	private function doneSlidePrev(_):Void
	{
		if (!_activated)
		{
			selectedItem = -1;
		}
		else
		{
			if (selectedItem == 0)
				selectedItem = 3;
			else
				selectedItem--;
		}	
		
		_sliding = false;
	}
	
	
	override public function draw():Void 
	{
		
		
		
		super.draw();
	}
	
}
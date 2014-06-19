package ;

import flash.display.BitmapData;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.tweens.misc.ColorTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import openfl.display.BitmapDataChannel;
using flixel.util.FlxSpriteUtil;

class BossSegment extends FlxSprite
{

	public var damageMod:Float = 1;
	private var _gfxBuffer:BitmapData;
	private var _gfxFlash:BitmapData;
	private var _flashTimer:FlxTimer;
	public var hurtCallback:Float->Void;
	
	public function new(X:Float, Y:Float)
	{
		super(X, Y);
		_flashTimer = new FlxTimer();
	}
	
	override public function makeGraphic(Width:Int, Height:Int, Color:FlxColor = FlxColor.WHITE, Unique:Bool = false, ?Key:String):FlxSprite 
	{
		var tmp:FlxSprite = super.makeGraphic(Width, Height, Color, Unique, Key);
		
		_gfxBuffer = new BitmapData(Width, Height, true, FlxColor.TRANSPARENT);
		_gfxBuffer.copyPixels(tmp.pixels, tmp.pixels.rect, _flashPointZero, tmp.pixels, _flashPointZero);
		
		_gfxFlash = new BitmapData(Width, Height, true, FlxColor.RED);
		_gfxFlash.copyChannel(_gfxBuffer, _gfxBuffer.rect, _flashPointZero, BitmapDataChannel.ALPHA, BitmapDataChannel.ALPHA);
		
		return tmp;
	}
	
	public function flash():Void
	{
		pixels.copyPixels(_gfxFlash, _gfxFlash.rect, _flashPointZero);
		dirty = true;
		_flashTimer.start(.1, finishFlash);
	}	
	
	private function finishFlash(_) 
	{ 
		pixels.copyPixels(_gfxBuffer, _gfxBuffer.rect, _flashPointZero); 
		dirty = true;
	}
	
	override public function hurt(Damage:Float):Void 
	{
		flash();
		hurtCallback(Damage * damageMod);
	}
	
	override public function kill():Void 
	{
		finishFlash(null);
		super.kill();
	}
}
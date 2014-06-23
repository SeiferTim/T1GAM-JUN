package ;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import haxe.Constraints.FlatEnum;
using flixel.math.FlxRandom;
using flixel.math.FlxVelocity;

class Explosion extends FlxSpriteGroup
{

	public function new() 
	{
		super();
		var s:ExplosionCloud;
		for (i in 1...10)
		{
			for (j in 0...5)
			{
				s = new ExplosionCloud(this);
				s.makeGraphic(i, i, FlxColor.WHITE);
				s.visible = false;
				s.drag.x = 100;
				s.drag.y = 100;
				add(s);
			}
		}
		
	}
	
	public function burst(X:Float, Y:Float):Void
	{
		
		reset(X, Y);
		
		var angle:Float = 0;
		var speed:Float = 0;
		var pivot:FlxPoint = FlxPoint.get();
		var _ptZero:FlxPoint = FlxPoint.get();
		
		for (i in 0...members.length)
		{
			members[i].revive();
			members[i].visible = true;
			members[i].alpha = 0;
			members[i].x = X + FlxRandom.int( -10, 10) - (members[i].width / 2);
			members[i].y = Y + FlxRandom.int( -10, 10) - (members[i].height / 2);
			angle = FlxAngle.wrapAngle(FlxRandom.float(1, 360));
			speed = FlxRandom.float(40, 100);
			pivot.set(0, speed);
			members[i].velocity.copyFrom(pivot.rotate(_ptZero, angle));
			FlxTween.num(0, 1, .2, { ease:FlxEase.sineOut, complete: function(T) { FlxTween.num(1, 0, .66, { ease:FlxEase.backIn, complete:function(T) { members[i].kill(); } }, members[i].set_alpha); } }, members[i].set_alpha);
		}
		
		pivot.put();
		_ptZero.put();
		
		members.shuffleArray(10);
	}
	
	override public function update():Void
	{
		if (countLiving() == 0)
		{
			kill();
		}
		super.update();
	}
	
	
	
}
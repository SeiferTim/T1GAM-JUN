package ;

interface IEnemy 
{
	public function reset(X:Float, Y:Float):Void;
	public function update():Void;
	public function destroy():Void;
	public function hurt(Damage:Float):Void;
	
	
}
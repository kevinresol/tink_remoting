package;

using tink.CoreApi;

@:keep
@:build(tink.remoting.macro.Macro.build())
class Api {
	public function new() {
		
	}
	
	public function foo(a:Int, b:Int):Int
		return a + b;
		
	@async
	public function boo(a:Int, b:Int):Future<Int>
		return Future.sync(a + b);
}
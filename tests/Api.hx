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
	public function bar(a:Int, b:Int):Future<Int>
		return Future.sync(a + b);
		
	public function foo2(a:Int, b:Int):Surprise<Int, Error>
		return Future.sync(Success(a + b));
		
	@async
	public function bar2(a:Int, b:Int):Outcome<Int, Error>
		return Success(a + b);
}
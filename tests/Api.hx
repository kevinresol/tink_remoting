package;

using tink.CoreApi;

class Api implements tink.remoting.Api {
	public function new() {
		
	}
	
	public function foo(a:Int, b:Int):Int
		return a + b;
		
	public function bar(a:Int, b:Int):Future<Int>
		return Future.sync(a + b);
		
	public function foo2(a:Int, b:Int):Surprise<Int, Error>
		return Future.sync(Success(a + b));
		
	public function bar2(a:Int, b:Int):Outcome<Int, Error>
		return Success(a + b);
	
	public function fail(a:Int, b:Int):Outcome<Int, Error>
		return Failure(new Error("my error"));
}
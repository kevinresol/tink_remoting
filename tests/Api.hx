package;

using tink.CoreApi;

class Api {
	public function new() {
		
	}
	
	public function foo(a:Int, b:Int)
		return a + b;
		
	@async
	public function boo(a:Int, b:Int)
		return Future.sync(a + b);
}
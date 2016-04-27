# tink_remoting [![Build Status](https://travis-ci.org/kevinresol/tink_remoting.svg?branch=master)](https://travis-ci.org/kevinresol/tink_remoting)

## Usage

0. First build your remoting API by implementing `tink.remoting.Api`
0. Prepare your remoting Context by extending `tink.remoting.Context`
0. Initialize your context in server and handle it
0. Initialize your context in client and call the api methods.

```haxe
class MyApi implements tink.remoting.Api {
	public function foo(a:Int, bar:Int):Int 
		return a + b;
}

class MyContext extends tink.remoting.Context {
	public var myApi:MyApi;
}

class Server {
	static function main() {
		var container = new NodeContainer(8081); // use a container of your choice
		var ctx = new MyContext();
		container.run({
			done: Future.trigger(),
			serve: function(req) return ctx.processRequest(req) >> function(result) return ctx.toResponse(result),
			onError: function(err) trace(err),
		});
	}
}

class Client {
	static function main() {
		var ctx = new MyContext('localhost', 8081);
		ctx.myApi.foo(1, 2).handle(function(o) switch(o) {
			case Success(result): trace(result); // 3
			case Failure(_):
		});
	}
}

```
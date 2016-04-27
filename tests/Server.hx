package;

import tink.http.Container;
import tink.remoting.Context;

using tink.CoreApi;

class Server {
	static function main() {
		var container = 
			#if nodejs
				new NodeContainer(8081);
			#else
				CgiContainer.instance;
			#end
		var ctx = new MyContext();
		container.run({
			done: Future.trigger(),
			serve: function(req) return ctx.processRequest(req) >> function(result) return ctx.toResponse(result),
			onError: function(err) trace(err),
		});
	}
}
package;

import tink.http.Container;
import tink.http.Response;
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
			serve: function(req) return ctx.processRequest(req),
			onError: function(err) trace(err),
		});
	}
}
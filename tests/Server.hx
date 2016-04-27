package;

import tink.http.Container;
import tink.remoting.Context;

using tink.CoreApi;

class Server {
	static function main() {
		var container = CgiContainer.instance;
		var ctx = new Context();
		ctx.addObject('Api', new Api());
		container.run({
			done: Future.trigger(),
			serve: function(req) {
				return ctx.processRequest(req) >> function(result) return ctx.toResponse(result);
			},
			onError: function(err) trace(err),
		});
	}
}
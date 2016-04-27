package;

import tink.remoting.Context;
import tink.remoting.Connection;
import tink.remoting.Client;
import tink.http.Request;

import buddy.*;
using buddy.Should;

using tink.CoreApi;
using TestConnection;

@:access(tink.remoting.Connection)
@:access(tink.remoting.Context)
class TestConnection extends BuddySuite {
	
	var ctx:Context;
	
	public function new() {
		super();
		ctx = new Context();
		ctx.addObject("Api", new Api());
		
		describe("Test Connection", {
			
			it("should serialize call", {
				var s = Connection.serializeCall('Api.foo', [1,2]);
				s.should.be('y7:Api.fooai1i2h');
			});
			
			it("should process serialized string", function(done) {
				var s = Connection.serializeCall('Api.foo', [1,2]);
				ctx.process(s).handle(function(o) switch o {
					case Success(data): 
						data.should.be('hxri3');
						done();
					case Failure(err): 
						fail(err);
				});
			});
			
			it("should process an incoming request", function(done) {
				var cnx = new Connection('host', 0, '/');
				var req = cnx.prepareRequest('Api.foo', [1,2]).toIncomingRequest();
				ctx.processRequest(req).handle(function(o) switch o {
					case None:
						fail("Context ignored the request unexpectedly");
					case Finish(data): 
						data.should.be('hxri3');
						done();
					case Fail(err): 
						fail(err);
				});
			});
		});
	}
	
	static function toIncomingRequest(req:OutgoingRequest) {
		return new IncomingRequest('fake_ip', new IncomingRequestHeader(req.header.method, req.header.uri, 'version', req.header.fields), req.body);
	}
}
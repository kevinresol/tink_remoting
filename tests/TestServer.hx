package;

import tink.remoting.Context;
import tink.http.Request;
import tink.http.Header;

import buddy.*;
using buddy.Should;

using tink.CoreApi;

@:access(tink.remoting.context.ServerContext)
class TestServer extends BuddySuite {
	
	#if tink_remoting_server
	var ctx:Context;
	
	public function new() {
		super();
		ctx = new MyContext();
		
		describe("Test Connection", {
			
			it("should process serialized string", function(done) {
				ctx.process('y7:Api.fooai1i2h').handle(function(o) {
					o.should.be('hxrwy17:tink.core.Outcomey7:Success:1i3');
					done();
				});
			});
			
			it("should process serialized string with packaged api", function(done) {
				ctx.process('y23:packaged_AnotherApi.fooai1i2h').handle(function(o) {
					o.should.be('hxrwy17:tink.core.Outcomey7:Success:1i3');
					done();
				});
			});
			
			it("should process an incoming request", function(done) {
				var req = request('y7:Api.fooai1i2h');
				
				ctx.processRequest(req).handle(function(o) switch o {
					case None:
						fail("Context ignored the request unexpectedly");
					case Finish(data): 
						data.should.be('hxrwy17:tink.core.Outcomey7:Success:1i3');
						done();
					case Fail(err): 
						fail(err);
				});
			});
			
			it("should process an incoming request with packaged api", function(done) {
				var req = request('y23:packaged_AnotherApi.fooai1i2h');
				
				ctx.processRequest(req).handle(function(o) switch o {
					case None:
						fail("Context ignored the request unexpectedly");
					case Finish(data): 
						data.should.be('hxrwy17:tink.core.Outcomey7:Success:1i3');
						done();
					case Fail(err): 
						fail(err);
				});
			});
			
			it("should fail an invalid request", function(done) {
				var req = request('y22:packaged_AnotherAp.fooai1i2h');
				
				ctx.processRequest(req).handle(function(o) switch o {
					case None:
						fail("Context ignored the request unexpectedly");
					case Finish(data):
						data.should.startWith('hxrwy17:tink.core.Outcomey7:Failure:1cy20:tink.core.TypedError');
						data.should.contain('packaged_AnotherAp');
						done();
					case Fail(err):
						fail(err);
				});
			});
		});
	}
	
	function request(serializedCall:String) 
		return new IncomingRequest(
			'fake_ip',
			new IncomingRequestHeader(POST, '/', null, [new HeaderField('x-tink-remoting', '1')]),
			'__x=$serializedCall'
		);
	#end
}
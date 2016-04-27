package;

import tink.remoting.Context;
import tink.remoting.Connection;
import tink.http.Request;
import haxe.unit.TestCase;

using tink.CoreApi;
using TestConnection;

@:access(tink.remoting.Connection)
class TestConnection extends TestCase {
	
	var ctx:Context;
	
	public function new() {
		super();
		ctx = new Context();
		ctx.addObject("Api", new Api());
	}
	
	public function testSerializeCall() {
		var s = Connection.serializeCall('Api.foo', [1,2]);
		assertEquals('ay3:Apiy3:foohai1i2h', s);
	}
	
	public function testProcess() {
		var s = Connection.serializeCall('Api.foo', [1,2]);
		assertEquals('hxri3', ctx.process(s).sure());
	}
	
	public function testProcessRequest() {
		var cnx = new Connection('host', 0, '/');
		var req = cnx.prepareRequest('Api.foo', [1,2]).toIncomingRequest();
		ctx.processRequest(req).handle(function(o) switch o {
			case Success(None): fail("Context ignored the request unexpectedly");
			case Success(Some(Success(data))): assertEquals('hxri3', data);
			case Success(Some(Failure(err))) | Failure(err): fail(err.toString());
		});
	}
	
	static function toIncomingRequest(req:OutgoingRequest) {
		return new IncomingRequest('fake_ip', new IncomingRequestHeader(req.header.method, req.header.uri, 'version', req.header.fields), req.body);
	}
	
	function fail(reason:String, ?c:haxe.PosInfos) {
		currentTest.done = true;
		currentTest.success = false;
		currentTest.error   = reason;
		currentTest.posInfos = c;
		throw currentTest;
	}
	
	
}
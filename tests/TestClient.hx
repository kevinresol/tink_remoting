package;

import tink.remoting.Context;
import tink.remoting.Connection;
import tink.remoting.Client;
import tink.http.Request;

import buddy.*;
using buddy.Should;

using tink.CoreApi;
using TestConnection;

class TestClient extends BuddySuite {
	
	var api = new Api();
	
	public function new() {
		
		Client.connection = new Connection('localhost', 8081);
		
		describe("Test Client", {
			it("should call remote function", function(done) {
				api.foo(1, 2).handle(function(o) switch o {
					case Success(result): 
						result.should.be(3);
						done();
					case Failure(err): 
						fail(err);
				});
			});
		});
	}
}
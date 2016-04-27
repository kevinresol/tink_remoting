package;

import tink.remoting.Context;
import tink.remoting.Connection;
import tink.http.Request;

import buddy.*;
using buddy.Should;

using tink.CoreApi;
using TestConnection;

class TestClient extends BuddySuite {
	
	public function new() {
		var ctx = new MyContext('localhost', 8081);
		
		describe("Test Client", {
			it("should call remote function (int)", function(done) {
				ctx.api.foo(1, 2).handle(function(o) switch o {
					case Success(result): result.should.be(3); done();
					case Failure(err): fail(err);
				});
			});
			
			it("should call remote function (int)", function(done) {
				ctx.api2.foo(1, 2).handle(function(o) switch o {
					case Success(result): result.should.be(3); done();
					case Failure(err): fail(err);
				});
			});
			
			it("should call remote function (future)", function(done) {
				ctx.api.bar(1, 2).handle(function(o) switch o {
					case Success(result): result.should.be(3); done();
					case Failure(err): fail(err);
				});
			});
			
			it("should call remote function (future)", function(done) {
				ctx.api2.bar(1, 2).handle(function(o) switch o {
					case Success(result): result.should.be(3); done();
					case Failure(err): fail(err);
				});
			});
			
			it("should call remote function (surprise)", function(done) {
				ctx.api.foo2(1, 2).handle(function(o) switch o {
					case Success(result): result.should.be(3); done();
					case Failure(err): fail(err);
				});
			});
			
			it("should call remote function (surprise)", function(done) {
				ctx.api2.foo2(1, 2).handle(function(o) switch o {
					case Success(result): result.should.be(3); done();
					case Failure(err): fail(err);
				});
			});
			
			it("should call remote function (outcome)", function(done) {
				ctx.api.bar2(1, 2).handle(function(o) switch o {
					case Success(result): result.should.be(3); done();
					case Failure(err): fail(err);
				});
			});
			
			it("should call remote function (outcome)", function(done) {
				ctx.api2.bar2(1, 2).handle(function(o) switch o {
					case Success(result): result.should.be(3); done();
					case Failure(err): fail(err);
				});
			});
		});
	}
}

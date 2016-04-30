package;

import tink.remoting.Context;

import buddy.*;
using buddy.Should;

using tink.CoreApi;

class TestClient extends BuddySuite {
	
	public function new() {
		var ctx = new MyContext('localhost', 18081);
		
		describe("Test Client", {
			
			it("should serialize call", {
				var s = @:privateAccess Context.serializeCall('Api.foo', [1,2]);
				s.should.be('y7:Api.fooai1i2h');
			});
			
			it("should serialize packaged call", {
				var s = @:privateAccess Context.serializeCall('packaged_AnotherApi.foo', [1,2]);
				s.should.be('y23:packaged_AnotherApi.fooai1i2h');
			});
			
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
			
			it("should get the remote error", function(done) {
				ctx.api.fail(1, 2).handle(function(o) switch o {
					case Success(result): fail('should not have result: $result');
					case Failure(err): err.message.should.be('my error'); done();
				});
			});
		});
	}
}

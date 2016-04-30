package tink.remoting.context;

import haxe.Unserializer;
import haxe.Serializer;
import haxe.rtti.Meta;
import tink.http.Response;
import tink.http.Request;
import tink.url.Query;

using tink.CoreApi;
using Reflect;

@:autoBuild(tink.remoting.macro.Macro.buildContext())
class ServerContext {
	
	@:skip
	var objects:Map<String, {obj:Dynamic, rec:Bool}>;
	
	public function new() {
		objects = new Map();
	}
	
	inline function addObject(name:String, obj:{}, rec:Bool = false) {
		objects.set(name, {obj: obj, rec: rec});
	}
	
	public function processRequest(request:IncomingRequest):ProcessResult {
		
		if(!request.header.byName('x-tink-remoting').isSuccess()) return Future.sync(None);
		
		return request.body.all().flatMap(function(o) switch o {
			case Success(bytes):
				var parser = (bytes.toString():Query).parse();
				
				while(parser.hasNext()) {
					var param = parser.next();
					if(param.name == '__x')
						return process(param.value).map(function(o) return Finish(o));
				}
				
				return Future.sync(Fail(new Error(BadRequest, 'Missing "__x" parameter')));
					
			case Failure(err):
				return Future.sync(Fail(err));
		});
	}
	
	function process(requestData:String):Future<String> {
		var u = new Unserializer(requestData);
		var path = u.unserialize();
		var args = u.unserialize();
		return call(path, args).map(function(o) return "hxr" + Serializer.run(o));
	}
	
	function call(path:String, params:Array<Dynamic>):Surprise<Dynamic, Error> {
		inline function fail(msg) return Future.sync(Failure(new Error(NotFound, msg)));
		
		var pathArr = path.split('.');
		if( pathArr.length < 2 ) return fail('Invalid path: $path');
		var inf = objects.get(pathArr[0]);
		if( inf == null ) return fail('No such object: ${pathArr[0]}');
		var o:Dynamic = inf.obj;
		var m:Dynamic = o.field(pathArr[1]);
		if(pathArr.length > 2) {
			if(!inf.rec) return fail('Cannot access: $path');
			for(i in 2...pathArr.length) {
				o = m;
				m = o.field(pathArr[i]);
			}
		}
		if(!m.isFunction()) return fail('No such method: $path');
			
		var meta = Meta.getFields(Type.getClass(o));
		var methodName = pathArr[pathArr.length - 1];
		var async = meta.hasField(methodName) && meta.field(methodName).hasField('async');
		var result = o.callMethod(m, params);
		if(async) {
			var future:Future<Dynamic> = cast result;
			return future >>
				function(result:Dynamic) return Std.is(result, Outcome) ? cast result : Success(result);
		}
		else 
			return Future.sync(Std.is(result, Outcome) ? cast result : Success(result));
	}
}

@:forward
abstract ProcessResult(Future<ProcessResultImpl>) from Future<ProcessResultImpl> to Future<ProcessResultImpl> {
	@:to
	public inline function toResponse():Future<OutgoingResponse> {
		inline function res(code, reason, body) return new OutgoingResponse(new ResponseHeader(code, reason, []), body);
		return this >> function(o) return switch o {
			case None: res(404, 'Not found', "Missing x-tink-remoting header");
			case Finish(result): res(200, 'OK', result);
			case Fail(err): res(err.code, err.message, "hxr" + Serializer.run(Failure(err)));
		}
	}
}

enum ProcessResultImpl {
	None;
	Finish(data:String);
	Fail(error:Error);
}
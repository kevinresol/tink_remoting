package tink.remoting;

import haxe.Unserializer;
import haxe.Serializer;
import haxe.rtti.Meta;
import tink.remoting.Request;
using tink.CoreApi;
using Reflect;

class Context {
	var objects:Map<String, {obj:Dynamic, rec:Bool}>;
	
	public function new() {
		objects = new Map();
	}
	
	public function addObject(name:String, obj:{}, rec:Bool = false) {
		objects.set(name, {obj: obj, rec: rec});
	}
	
	public function processRequest(request:Request):Future<ProcessResult> {
		
		if(!request.header.byName('x-tink-remoting').isSuccess()) return Future.sync(None);
		
		return request.getParams().flatMap(function(o) return switch(o) {
			case Success(params):
				if(params.exists('__x'))
					process(params['__x']).map(function(o) return switch o {
						case Success(result): Finish(result);
						case Failure(err): Fail(err);
					});
				else
					Future.sync(Fail(new Error(BadRequest, 'Missing "__x" parameter')));
			case Failure(err):
				Future.sync(Fail(err));
		});
	}
	
	public function process(requestData:String):Surprise<String, Error> {
		var u = new Unserializer(requestData);
		var path = u.unserialize();
		var args = u.unserialize();
		return call(path, args) >>
			function(result:Dynamic) return "hxr" + Serializer.run(result);
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

enum ProcessResult {
	None;
	Finish(data:String);
	Fail(error:Error);
}


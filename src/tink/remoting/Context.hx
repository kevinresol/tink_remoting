package tink.remoting;

import haxe.ds.Option;
import haxe.Unserializer;
import haxe.Serializer;
import tink.remoting.Request;
using tink.CoreApi;

class Context extends haxe.remoting.Context {
	
	public function processRequest(request:Request) {
		
		if(!request.header.byName('x-tink-remoting').isSuccess()) return Future.sync(Success(None));
		
		return request.getParams() >>
			function(params:Map<String, String>) {
				if(params.exists('__x')) {
					return Some(process(params['__x']));
				} else
					return Some(Failure(Error.withData(BadRequest, 'Missing "__x" parameter', null)));
			}
	}
	
	public function process(requestData:String) {
		try {
			var u = new Unserializer(requestData);
			var path = u.unserialize();
			var args = u.unserialize();
			var data = call(path, args);
			return Success("hxr" + Serializer.run(data));
		} catch(e:Dynamic) {
			var s = new Serializer();
			s.serializeException(e);
			return Success("hxr" + s.toString());
		}
	}
}


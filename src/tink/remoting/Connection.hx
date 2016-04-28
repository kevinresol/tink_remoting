package tink.remoting;

import haxe.Serializer;
import haxe.Unserializer;
import haxe.io.Bytes;
import tink.http.Request;
import tink.http.Response;
import tink.http.Header;
import tink.http.Client;

using tink.CoreApi;

class Connection {
	
	var host:String;
	var port:Int;
	
	/** Server should handle remoting at this path **/
	var uri:String;
	
	var client:Client;
	
	public function new(host:String, port:Int, uri:String = '/') {
		this.host = host;
		this.port = port;
		this.uri = uri;
		this.client = 
			#if tink_tcp
				new TcpClient();
			#elseif nodejs
				new NodeClient();
			#else
				new StdClient();
			#end 
	}
	
	public function call<T>(path:String, params:Array<Dynamic>):Surprise<T, Error> {
		var req = prepareRequest(path, params);
		
		return client.request(req) >>
			function(res:IncomingResponse)
				return res.body.all() >> function(bytes:Bytes) {
					var data = bytes.toString();
					if(data.substr(0, 3) != 'hxr') return Failure(new Error(UnprocessableEntity, 'Invalid Response: "$data"'));
					data = data.substr(3);
					return Unserializer.run(data);
				}
	}
	
	inline function prepareRequest(path:String, params:Array<Dynamic>) {
		var body = "__x=" + serializeCall(path, params);
		return new OutgoingRequest(
			new OutgoingRequestHeader(POST, host, port, uri, null, [new HeaderField('x-tink-remoting', '1'), new HeaderField('content-length', '${body.length}')]),
			body
		);
	}
	
	static inline function serializeCall(path:String, params:Array<Dynamic>):String {
		var s = new Serializer();
		s.serialize(path);
		s.serialize(params);
		return s.toString();
	}
}
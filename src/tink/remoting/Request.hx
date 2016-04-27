package tink.remoting;

import haxe.io.Bytes;
import tink.http.Request;
import tink.url.Query;
using tink.CoreApi;

@:forward
abstract Request(IncomingRequest) from IncomingRequest to IncomingRequest {
	public function getParams() {
		var query = this.header.uri.query;
		
		var post = 
			if(!this.header.byName('Content-Length').isSuccess() || this.header.method != POST) 
				Future.sync(Success('')) 
			else 
				this.body.all() >> function(bytes:Bytes) return bytes.toString();
		
		return post >>
			function(postString:String)
				return [
					for (raw in [query, postString]) 
						if(raw != null) for (p in raw.parse())
							p.name => p.value
					];
	}
}
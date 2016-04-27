package;

import buddy.*;

class RunTests implements Buddy<[
	#if tink_remoting_client
		TestClient,
	#end
		
	#if tink_remoting_server
		TestConnection,
	#end
]>{}
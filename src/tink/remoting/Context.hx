package tink.remoting;

#if tink_remoting_client
typedef Context = tink.remoting.context.ClientContext;
#end

#if tink_remoting_server
typedef Context = tink.remoting.context.ServerContext;
#end


package tink.remoting.macro;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

using tink.CoreApi;
#if macro
using tink.MacroApi;
#end

class Macro {
	public static function build():Array<Field> {
		var isClient = Context.defined('tink_remoting_client');
		var isServer = Context.defined('tink_remoting_server');
		
		if((isClient && isServer) || (!isClient && !isServer)) return null; // TODO: what should we do?
		
		return isClient ? buildClient() : buildServer();
	}
	
	static function buildClient() {
		var cl = Context.getLocalClass().get();
		var fields:Array<Member> = Context.getBuildFields();
		
		// transform member functions
		processFunctions(fields, new ClientProcessor(cl.name));
		
		// add the cnx field
		fields.push({
			name: 'cnx',
			kind: FieldType.FVar(macro:tink.remoting.Connection, macro tink.remoting.Client.connection),
			pos: Context.currentPos(),
		});
		
		return fields;
	}
	
	static function buildServer() {
		return null;
	}
	
	static function processFunctions(fields:Array<Member>, processor:Processor) {
		for(f in fields) {
			if(f.name == 'new') continue;
			switch f.getFunction() {
				case Success(func):
					if(func.ret == null) Context.error('Requires explicit return type', f.pos);
					var type = func.ret.toType().sure();
					switch type.getID() {
						case 'tink.core.Future':
							switch Context.follow(type) {
								case TAbstract(_, [typeParam]):
									if(typeParam.getID() == 'tink.core.Outcome')
										processor.surprise(f.name, func, extractOutcome(typeParam));
									else
										processor.future(f.name, func, typeParam);
								default:
									throw "assert";
							}
						case 'tink.core.Outcome':
							processor.outcome(f.name, func, extractOutcome(type));
						default:
							processor.other(f.name, func, type);
					}
				default:
			}
		}
	}
	
	static function extractOutcome(type:Type) {
		switch Context.follow(type) {
			case TEnum(_, [s, f]): return new Pair(s, f);
			default: throw 'assert';
		}
	}
}

typedef Processor = {
	function future(name:String, func:Function, type:Type):Void;
	function outcome(name:String, func:Function, type:Pair<Type, Type>):Void;
	function surprise(name:String, func:Function, type:Pair<Type, Type>):Void;
	function other(name:String, func:Function, type:Type):Void;
}

class ClientProcessor {
	
	var cl:String;
	
	public function new(cl:String) {
		this.cl = cl;
	}
	
	public function future(name:String, func:Function, type:Type) {
		var ct = type.toComplex();
		func.ret = macro:tink.CoreApi.Surprise<$ct, tink.CoreApi.Error>;
		buildClientBody(name, func);
	}
	
	public function outcome(name:String, func:Function, type:Pair<Type, Type>) {
		var s = type.a.toComplex();
		var f = type.b.toComplex();
		func.ret = macro:tink.CoreApi.Surprise<$s, $f>;
		buildClientBody(name, func);
	}
	
	public function surprise(name:String, func:Function, type:Pair<Type, Type>) {
		buildClientBody(name, func);
	}
	
	public function other(name:String, func:Function, type:Type) {
		var ct = type.toComplex();
		func.ret = macro:tink.CoreApi.Surprise<$ct, tink.CoreApi.Error>;
		buildClientBody(name, func);
	}
	
	function buildClientBody(name:String, func:Function) {
		var args = func.args.map(function(a) return macro $i{a.name});
		func.expr = macro return cnx.call($v{cl + '.' + name}, $a{args});
	}

}

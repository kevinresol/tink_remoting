package tink.remoting.macro;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

using tink.CoreApi;
using StringTools;

#if macro
using tink.MacroApi;
#end

class Macro {
	
	public static function buildContext():Array<Field> {
		
		var isClient = Context.defined('tink_remoting_client');
		var isServer = Context.defined('tink_remoting_server');
		
		return ClassBuilder.run([
			function(cb:ClassBuilder) {
				
				var ctor = cb.getConstructor();
				var apis = [];
				
				for(member in cb) {
					switch member.extractMeta(':skip') {
						case Success(_): continue;
						default:
					}
					switch member.getVar(true) {
						case Success({type: ct}):
							var name = ct.toType().sure().getID();
							var tp = switch ct {
								case TPath(tp): tp;
								default: throw 'assert';
							}
							ctor.addStatement(macro $i{member.name} = new $tp());
							if(isClient)
								ctor.addStatement(macro @:privateAccess $i{member.name}.cnx = cnx);
							else
								apis.push({identifier: member.name, type: name.replace('.', '_')});
						default:
					}
				}
				
				if(isServer) {
					ctor.addStatement(macro init());
					
					cb.addMember({
						name: 'init',
						pos: Context.currentPos(),
						kind: FFun({
							args: [],
							ret: null,
							expr: macro $b{[for(api in apis)
								macro addObject($v{api.type}, $i{api.identifier})
							]}
						}),
					});
				}
			}
		]);
	}
	
	public static function buildApi():Array<Field> {
		var isClient = Context.defined('tink_remoting_client');
		var isServer = Context.defined('tink_remoting_server');
		
		if((isClient && isServer) || (!isClient && !isServer)) return null; // TODO: what should we do?
		
		return isClient ? buildClientApi() : buildServerApi();
	}
	
	static function buildClientApi() {
		return ClassBuilder.run([
			processFunctions.bind(_, new ClientProcessor()),
			keepFunctions,
			function(cb:ClassBuilder) {
				cb.addMember({
					name: 'cnx',
					kind: FieldType.FVar(macro:tink.remoting.Connection, null),
					pos: Context.currentPos(),
				});
			}
		]);
	}
	
	static function buildServerApi() {
		return ClassBuilder.run([
			keepFunctions,
		]);
	}
	
	static function processFunctions(cb:ClassBuilder, processor:Processor) {
		processor.className = (cb.target.pack.length == 0 ? '' : cb.target.pack.join('_') + '_') + cb.target.name;
		for(field in cb) {
			if(field.name == 'new') continue;
			switch field.getFunction() {
				case Success(func) if(field.isPublic):
					if(func.ret == null) Context.error('Requires explicit return type', field.pos);
					
					switch func.ret.toType().sure().reduce() {
						case TAbstract(a, [TEnum(e, [s, f])]) if(a.toString() == 'tink.core.Future' && e.toString() == 'tink.core.Outcome'):
							processor.surprise(field.name, func, new Pair(s, f));
							
						case TAbstract(a, [typeParam]) if(a.toString() == 'tink.core.Future'):
							processor.future(field.name, func, typeParam);
							
						case TEnum(e, [s, f]) if(e.toString() == 'tink.core.Outcome'):
							processor.outcome(field.name, func, new Pair(s, f));
						
						case type:
							processor.other(field.name, func, type);
					}
				default:
			}
		}
	}
	
	// add @:keep to all public functions
	static function keepFunctions(cb:ClassBuilder) {
		for(field in cb) {
			if(field.name == 'new') continue;
			switch field.kind {
				case FFun(_) if(field.isPublic):
					field.addMeta(':keep');
				default:
			}
		}
	}
}

typedef Processor = {
	var className:String;
	function future(name:String, func:Function, type:Type):Void;
	function outcome(name:String, func:Function, type:Pair<Type, Type>):Void;
	function surprise(name:String, func:Function, type:Pair<Type, Type>):Void;
	function other(name:String, func:Function, type:Type):Void;
}

class ClientProcessor {
	
	public var className:String;
	
	public function new() {
		
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
		func.expr = macro return cnx.call($v{className + '.' + name}, $a{args});
	}

}

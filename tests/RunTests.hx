package;

import haxe.unit.TestRunner;

class RunTests {
	
	static function main() {
		var r = new TestRunner();
		r.add(new TestConnection());
		if(r.run()) {
			#if sys Sys.exit(500); #end
		}
	}
}
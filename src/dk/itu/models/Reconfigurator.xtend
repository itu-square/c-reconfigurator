package dk.itu.models

import dk.itu.models.tests.Test
import dk.itu.models.tests.Test1
import xtc.lang.cpp.PresenceConditionManager

class Reconfigurator {
	
	// per test settings
	static public var Test test
	static public var PresenceConditionManager presenceConditionManager
	
	
	
	
	
	
	
	def static void main(String[] args) {
		run(new Test1("test\\eb91f1d\\in.c"))
		
//		run(new Test2("test\\002\\in.c"))
		
//		run(new Test1("test\\002\\in.c"))
	}
	
	def static void run(Test test) {
		
		Reconfigurator::test = test
		println("Reconfigurator START")
		var newargs = #[
			"-silent",
//			"-Onone",
//			"-naiveFMLR",
//			"-lexer",
			"-no-exit",
			"-U", "__cplusplus",
			"-I", "gcc\\",
//			"-showActions",
//			"-follow-set",
//			"-printAST",
//			"-printSource",
			"-saveLayoutTokens",
			"-nostdinc",
			"-showErrors"
//			"-headerGuards",
//			"-macroTable",
//			"-E",
		]
		
//		var noargs = #[]
		
		test.run(newargs)
		
		println("Reconfigurator END")
	}

}

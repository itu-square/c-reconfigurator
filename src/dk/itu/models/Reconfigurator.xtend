package dk.itu.models

import xtc.lang.cpp.SuperC
import dk.itu.models.tests.Test1
import dk.itu.models.tests.Test

class Reconfigurator {
	
	static public var Test test
	
	def static void main(String[] args) {
		run(new Test1("test\\003\\in.c"))
		
//		run(new Test2("test\\002\\in.c"))
		
		run(new Test1("test\\002\\in.c"))
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
		
		
		var noargs = #[]
		
		test.run(newargs)
		
		//new SuperC().run(newargs)
//		new SuperC().process("D:\\temp\\superc\\c1.cpp");
		
		println("Reconfigurator END")
	}

}

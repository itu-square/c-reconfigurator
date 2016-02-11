package itu

import xtc.lang.cpp.SuperC

class Reconfigurator {
	
	def static void main(String[] args) {
		
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
			"-showErrors",
//			"-headerGuards",
//			"-macroTable",
//			"-E",
//			"/home/alex/busybox/busybox-1.24.1/scripts/echo.c",
//			"test\\003\\in.c"
			"test\\eb91f1d\\in.c"
		]
		
		
		var noargs = #[]
		
		new SuperC().run(newargs)
//		new SuperC().process("D:\\temp\\superc\\c1.cpp");
		
		println("Reconfigurator END")
	}

}

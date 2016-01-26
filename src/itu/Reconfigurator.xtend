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
//			"-showActions",
//			"-follow-set",
//			"-printAST",
//			"-printSource",
			"-saveLayoutTokens",
			"-nostdinc",
			"-showErrors",
//			"-E",
//			"/home/alex/busybox/busybox-1.24.1/scripts/echo.c",
			"test\\001\\c1.cpp"
//			"/home/alex/test/cpp/c2.cpp",
		]
		
		
		var noargs = #[]
		
		new SuperC().run(newargs)
//		new SuperC().process("D:\\temp\\superc\\c1.cpp");
		
		println("Reconfigurator END")
	}

}

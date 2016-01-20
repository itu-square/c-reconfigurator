package itu

import java.util.List
import xtc.lang.cpp.SuperC

class Reconfigurator {
	
	def static void main(String[] args) {
    	println("Reconfigurator START")
    	
 		val List<String> newargs = #[
 			"-silent",
// 			"-Onone",
//			"-naiveFMLR",
//			"-lexer",
 			"-no-exit",
// 			"-showActions",
// 			"-follow-set",
			"-printAST",
			"-printSource",
			"-nostdinc",
//			"-E",
//			"/home/alex/busybox/busybox-1.24.1/scripts/echo.c"
			"test\\001\\c1.cpp"
//			"/home/alex/test/cpp/c2.cpp"
			]
				
		val List<String> noargs = #[]
		
		new SuperC().run(newargs);
		//new SuperC().process("D:\\temp\\superc\\c1.cpp");
		
		println("Reconfigurator END")
  	}
}
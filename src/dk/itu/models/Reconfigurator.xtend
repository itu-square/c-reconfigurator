package dk.itu.models

import dk.itu.models.preprocessor.Preprocessor
import dk.itu.models.tests.Test
import dk.itu.models.tests.Test1
import java.util.Map
import org.apache.commons.io.FileUtils
import xtc.lang.cpp.PresenceConditionManager
import java.io.File

class Reconfigurator {
	
	// per test settings
	static public var Test test
	static public var PresenceConditionManager presenceConditionManager
	static public var Map<String, String> transformedFeaturemap
	static public var Preprocessor preprocessor
	
	def static void run(Test test) {
		Reconfigurator::test = test
		var args = #[
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
		
		println(args)
		test.run(args)
	}
	
	public static def String relativeTo(String path, String base) {
		if (path.startsWith(base)) { '''«path.substring(base.length)»''' }
		else path
	}
	
	def static void reconfigure(File currentFile, (String)=>Test test) {
		val currentRelativePath = currentFile.path.relativeTo(Settings.source.path)
		val currentTargetPath = Settings::target + currentRelativePath

		if(currentFile.isDirectory) {
			val targetDir = new File(currentTargetPath)
			if (!targetDir.exists) {
				println('''making directory .«currentRelativePath»''')
			}
			currentFile.listFiles.forEach[reconfigure(test)]
		}
		else {
			if(currentFile.path.endsWith(".c") || currentFile.path.endsWith(".h")) {
				println('''processing file  .«currentRelativePath»''')
			}
			else {
				println('''ignoring file    .«currentRelativePath»''')
			}
		}
	}
	
	def static void main(String[] args) {
		println("Reconfigurator START")
		println("-- Models Team : ITU.dk (2016) --")
		println
		
//		if (!Settings::init(args)) return;

//		val String[] testargs = #[
//			"-source", "D:\\eclipse_xtc_test\\vbdb-linux\\eb91f1d.c",
//			"-target", "D:\\eclipse_xtc_test\\vbdb-linux-target\\eb91f1d.c",
//			"-oracle", "D:\\eclipse_xtc_test\\vbdb-linux-oracle\\eb91f1d.c",
//			"-include", "D:\\eclipse_xtc_test\\vbdb-linux-headers" ]
//		if (!Settings::init(testargs)) return;

		val String[] testargs = #[
			"-source", "D:\\eclipse_xtc_test\\vbdb-linux",
			"-target", "D:\\eclipse_xtc_test\\vbdb-linux-target",
			"-oracle", "D:\\eclipse_xtc_test\\vbdb-linux-oracle",
			"-include", "D:\\eclipse_xtc_test\\vbdb-linux-headers" ]
		if (!Settings::init(testargs)) return;
		
		if (Settings::target.isDirectory) FileUtils.deleteDirectory(Settings::target)
		else { 
			Settings::target.delete
			Settings::reconfig.delete
		}
		
		reconfigure(Settings::source, [String f | new Test1(f)])
		
		println("Reconfigurator DONE")
	}

}

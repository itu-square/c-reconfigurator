package dk.itu.models

import dk.itu.models.preprocessor.Preprocessor
import dk.itu.models.tests.Test
import dk.itu.models.tests.Test2
import java.util.Map
import org.apache.commons.io.FileUtils
import xtc.lang.cpp.PresenceConditionManager
import java.io.File
import static extension dk.itu.models.Extensions.*
import java.util.ArrayList

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
		
		var newArgs = new ArrayList<String>
		for (File include : Settings::includes) {
			newArgs.addAll(args)
			newArgs.addAll("-I", include.path) }
		
		test.run(newArgs)
	}
	
	def static void reconfigure(File currentFile, (String)=>Test test) {
		val currentRelativePath = currentFile.path.relativeTo(Settings.source.path)
		val currentTargetPath = Settings::target + currentRelativePath

		if(currentFile.isDirectory) {
			val targetDir = new File(currentTargetPath)
			if (!targetDir.exists) {
				println('''making directory .«currentRelativePath»''')
				targetDir.mkdirs
			}
			currentFile.listFiles.forEach[reconfigure(test)]
		}
		else {
			if(currentFile.path.endsWith(".c") || currentFile.path.endsWith(".h")) {
				println('''processing file  .«currentRelativePath»''')
				preprocessor.runFile(currentFile.path).toString.writeToFile(currentTargetPath)
				test.apply(currentTargetPath).run
			}
			else {
				println('''ignoring file    .«currentRelativePath»''')
				//FileUtils.copyFile(file, new File(targetPath))
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
		
		preprocessor = new Preprocessor
		Reconfigurator::transformedFeaturemap = preprocessor.mapFeatureAndTransformedFeatureNames
		
		reconfigure(Settings::source, [String f | new Test2(f)])
		
		println('''writing file     .«Settings::reconfig.path.relativeTo(Settings.target.path)»''')
		preprocessor.writeReconfig(Settings::reconfig.path)
		
		println("Reconfigurator DONE")
	}

}

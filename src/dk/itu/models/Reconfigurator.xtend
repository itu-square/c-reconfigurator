package dk.itu.models

import dk.itu.models.preprocessor.Preprocessor
import dk.itu.models.tests.Test
import dk.itu.models.tests.Test3
import java.io.File
import java.util.ArrayList
import java.util.Map
import org.apache.commons.io.FileUtils
import xtc.lang.cpp.PresenceConditionManager

import static extension dk.itu.models.Extensions.*

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
		newArgs.addAll(args)
		for (File include : Settings::includeFiles) {
			newArgs.addAll("-I", include.path) }
		
		test.run(newArgs)
	}
	
	def static void reconfigure(File currentFile, (String)=>Test test) {
		val currentRelativePath = currentFile.path.relativeTo(Settings::sourceFile.path)
		val currentTargetPath = Settings::targetFile + currentRelativePath

		if(currentFile.isDirectory) {
			val targetDir = new File(currentTargetPath)
			if (!targetDir.exists) {
				println('''making directory .«currentRelativePath»''')
				targetDir.mkdirs
				summaryln('''md                  .«currentRelativePath»''')
			}
			currentFile.listFiles.filter[isFile].forEach[reconfigure(test)]
			currentFile.listFiles.filter[isDirectory].forEach[reconfigure(test)]
		}
		else {
			if(currentFile.path.endsWith(".c") || currentFile.path.endsWith(".h")) {
				println('''processing file  .«currentRelativePath»''')
				flushConsole
				Settings::consolePS.flush
				
				preprocessor.runFile(currentFile.path).toString.writeToFile(currentTargetPath)
				test.apply(currentTargetPath).run
				
				var sum_console = Settings::consoleBAOS.toString
				var sum_parse = if (sum_console.contains("error: parse error")) "PARSE_ERR" else ( if (sum_console.contains("Exception")) "EXCEPTION" else "PARSE_OK ")
				var sum_result = if (sum_console.contains("result: #if")) "#if" else "   "
				var sum_oracle = if (sum_console.contains("oracle: pass")) "Opass"
					else if (sum_console.contains("oracle: pass")) "Ofail"
					else "     "
				summaryln('''«sum_parse» «sum_result» «sum_oracle» .«currentRelativePath»''')
			}
			else {
				println('''ignoring file    .«currentRelativePath»''')
				//FileUtils.copyFile(file, new File(targetPath))
				summaryln('''ig                .«currentRelativePath»''')
			}
		}
	}
	
	def static void main(String[] args) {
		Settings::captureOutput
		println("Reconfigurator START")
		println("-- Models Team : ITU.dk (2016) --")
		println
		
		try {
//			if (!Settings::init(args)) throw new Exception("Settings initialization error.");
	
			val String[] testargs = #[
				"-source",  "D:\\eclipse_xtc_test\\test-source\\",
				"-target",  "D:\\eclipse_xtc_test\\test-target\\",
				"-oracle",  "D:\\eclipse_xtc_test\\test-oracle\\",
				"-include", "D:\\eclipse_xtc_test\\test-headers\\"
			]
			if (!Settings::init(testargs)) throw new Exception("Settings initialization error.");
			
			if (Settings::targetFile.isDirectory) {
				FileUtils.deleteDirectory(Settings::targetFile)
				Settings::targetFile.mkdir
				}
			else { 
				Settings::targetFile.delete
				Settings::reconfigFile.delete
				Settings::consoleFile.delete
				Settings::summaryFile.delete
				Settings::targetFile.parentFile.mkdir
			}
			
			preprocessor = new Preprocessor
			Reconfigurator::transformedFeaturemap = preprocessor.mapFeatureAndTransformedFeatureNames
			
			reconfigure(Settings::sourceFile, [String f | new Test3(f)])
			
			println('''writing file     .«Settings::reconfigFile.path.relativeTo(Settings::targetFile.path)»''')
			preprocessor.writeReconfig(Settings::reconfigFile.path)
		} catch (Exception ex) {
			print(ex)
		}
			
		println
		println("Reconfigurator DONE")
		
		
		flushConsole
		Settings::summaryBAOS.toString.writeToFile(Settings.summaryFile.path)
		
		Settings::systemOutPS.append(Settings::consoleBAOS.toString)
		Settings::systemOutPS.flush
		
		
	}

}

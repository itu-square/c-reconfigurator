package dk.itu.models

import dk.itu.models.preprocessor.Preprocessor
import dk.itu.models.tests.Test
import dk.itu.models.tests.Test5
import java.io.File
import java.util.ArrayList
import java.util.Map
import xtc.lang.cpp.PresenceConditionManager

import static extension dk.itu.models.Extensions.*

class Reconfigurator {
	
	// per test settings
	static public var Test test
	static public var String file
	static public var long timeAfterParsing
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
//			"-showActions",
//			"-verbose",
//			"-follow-set",
//			"-printAST",
//			"-printSource",
			"-saveLayoutTokens",
			"-nostdinc",
			"-showErrors"
//			"-headerGuards",
//			"-macroTable",
//			,"-E"
		]
		
		var newArgs = new ArrayList<String>
		newArgs.addAll(args)
		for (String defineMacro : Settings.defineMacros) {
			newArgs.add("-D")
			newArgs.add(defineMacro) }
		for (String undefMacro : Settings::undefMacros) {
			newArgs.add("-U")
			newArgs.add(undefMacro) }
		for (File include : Settings::systemIncludeFolders) {
			newArgs.addAll("-isystem", include.path) }
		for (File include : Settings::includeFolders) {
			newArgs.addAll("-I", include.path) }
		for (File header : Settings::headerFiles) {
			newArgs.addAll("-include", header.path.replace("\\", "\\\\")) }
		
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
				summaryln('''| md    |       |       |       |       |       |       |       | .«currentRelativePath»''')
			}
			currentFile.listFiles.filter[isFile].forEach[reconfigure(test)]
			currentFile.listFiles.filter[isDirectory].forEach[reconfigure(test)]
		}
		else {
			var File oracle = null
			if(Settings::oracleFile != null) {
				oracle = new File(currentFile.path.replace(Settings::sourceFile.path, Settings::oracleFile.path) + ".ast")
			}
			if (
				(!Settings::oracleOnly || oracle != null && oracle.exists)
				&& (currentFile.path.endsWith(".c") || currentFile.path.endsWith(".h"))
				&& (Settings::ignorePattern == null || !Settings::ignorePattern.matcher(currentFile.path).matches)
			) {
				println
				println('''processing file  .«currentRelativePath»''')
				flushConsole
				Settings::consolePS.flush
				
				var double startingTime = 0
				timeAfterParsing = 0
				var double timeAfterPreprocessing = 0
				var double timeAfterReconfiguring = 0
				
				startingTime = System.nanoTime()
				timeAfterParsing = 0;
				preprocessor.runFile(currentFile.path).toString.writeToFile(currentTargetPath)
				timeAfterPreprocessing = System.nanoTime()
				test.apply(currentTargetPath).run
				timeAfterReconfiguring = System.nanoTime()
				
				val sum_console = Settings::consoleBAOS.toString
				val sum_header =
					if (sum_console.contains("error: header"))		" ERR   "
					else											" OK    "
				
				val sum_parse =
					if (sum_console.contains("error: parse error")) " ERR   "
					else ( if (sum_console.contains("Exception")) 	" EXCPT "
					else 											" OK    ")
				val sum_check1 =
					if (sum_console.contains("check: ContainsIf1")) " #if1  "
					else 											"       "
				var sum_result =
					if (sum_console.contains("result: #if")) 			"   #if "
					else (if (sum_console.contains("result: no#if")) 	" no#if "
					else 												"   -   ")
					
				var sum_oracle =
					if (sum_console.contains("oracle: pass")) 			" Opass "
					else (if (sum_console.contains("oracle: fail")) 	" Ofail "
					else 												" O-    ")
				
				// computing milliseconds
				val String preprocessingEstimate = 
					if (timeAfterPreprocessing != 0)
						String.format(" %5.1f ", (timeAfterPreprocessing - startingTime)/ 1000000)
					else "   -   "
				val String parsingEstimate = 
					if (timeAfterParsing != 0)
						String.format(" %5.1f ", (timeAfterParsing - timeAfterPreprocessing)/ 1000000)
					else "   -   "
				val String recofiguringEstimate = 
					if (timeAfterReconfiguring != 0)
						String.format(" %5.1f ", (timeAfterReconfiguring - timeAfterParsing)/ 1000000)
					else "   -   "
				
				summaryln('''|«sum_header»|«sum_parse»|«sum_check1»|«sum_oracle»|«sum_result»|«preprocessingEstimate»|«parsingEstimate»|«recofiguringEstimate»| .«currentRelativePath»''')
			}
			else {
				println
				println('''ignoring file    .«currentRelativePath»''')
				//FileUtils.copyFile(file, new File(targetPath))
				summaryln('''| ig    |       |       |       |       |       |       |       | .«currentRelativePath»''')
			}
		}
	}
	
	def static void main(String[] args) {
		Settings::captureOutput
		println("Reconfigurator START")
		println("-- Models Team : ITU.dk (2016) --")
		println
		
		try {
			val (String)=>Test test = [String f | new Test5(f)]
			
			if (!Settings::init(args)) throw new Exception("Settings initialization error.");
			
			if (Settings::targetFile.isDirectory) {
				Settings::targetFile.listFiles.forEach[delete]
				}
			else {
				if(Settings::targetFile.parentFile.exists) {
					new File(Settings::targetFile.parent).listFiles()
						.filter[name.startsWith(Settings::targetFile.name)]
						.forEach[delete]
					Settings::reconfigFile.delete
					Settings::consoleFile.delete
					Settings::summaryFile.delete
				}
				Settings::targetFile.parentFile.mkdir
			}
			
			preprocessor = new Preprocessor
			transformedFeaturemap = preprocessor.mapFeatureAndTransformedFeatureNames
			
			summaryln('''----------------------------------------------------------------------------------------''')
			summaryln('''| HEADR | PARSE | CHEK1 | ORACL | #IFS  | ¤prep | ¤pars | ¤reco | FILE -----------------''')
			summaryln('''----------------------------------------------------------------------------------------''')
			reconfigure(Settings::sourceFile, test)
			summaryln('''----------------------------------------------------------------------------------------''')
			
			println('''writing file     .«Settings::reconfigFile.path.relativeTo(Settings::targetFile.path)»''')
			preprocessor.writeReconfig(Settings::reconfigFile.path)
		} catch (Exception ex) {
			print(ex)
		}
			
		println
		println("Reconfigurator DONE")
		
		
		flushConsole
		
		Settings::systemOutPS.append(Settings::consoleBAOS.toString)
		Settings::systemOutPS.flush
		
		Settings::summaryBAOS.toString.writeToFile(Settings.summaryFile.path)
		Settings::systemOutPS.append(Settings::summaryBAOS.toString)
		Settings::systemOutPS.flush
	}

}

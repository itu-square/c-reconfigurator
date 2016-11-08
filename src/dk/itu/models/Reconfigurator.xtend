package dk.itu.models

import dk.itu.models.preprocessor.Preprocessor
import dk.itu.models.transformations.TxMain
import dk.itu.models.transformations.TxRemActions
import java.io.File
import java.util.ArrayList
import java.util.Map
import xtc.lang.cpp.PresenceConditionManager
import xtc.lang.cpp.SuperC
import xtc.tree.Node

import static extension dk.itu.models.Extensions.*

class Reconfigurator {
	
//	// per test settings
//	static public var Test test
	static public var String file
//	static public var long timeAfterParsing
	static public var PresenceConditionManager presenceConditionManager
	static public var Map<String, String> transformedFeaturemap
	static public var Preprocessor preprocessor
	static public var ArrayList<String> errors
	
//	static public var Report report
//	
//	static public var int processedFiles = 0
//	
//	def static void run(Test test) {
//		Reconfigurator::test = test
//		var args = #[
//			"-silent",
////			"-Onone",
////			"-naiveFMLR",
////			"-lexer",
//			"-no-exit",
//			"-nobuiltins",
////			"-showActions",
////			"-verbose",
////			"-follow-set",
////			"-printAST",
////			"-printSource",
//			"-saveLayoutTokens",
//			"-nostdinc",
//			"-showErrors"
////			"-headerGuards",
////			"-macroTable",
////			,"-E"
//		]
//		
//		var newArgs = new ArrayList<String>
//		newArgs.addAll(args)
//		for (String defineMacro : Settings.defineMacros) {
//			newArgs.add("-D")
//			newArgs.add(defineMacro) }
//		for (String undefMacro : Settings::undefMacros) {
//			newArgs.add("-U")
//			newArgs.add(undefMacro) }
//		for (File include : Settings::systemIncludeFolders) {
//			newArgs.addAll("-isystem", include.path) }
//		for (File include : Settings::includeFolders) {
//			newArgs.addAll("-I", include.path) }
//		for (File header : Settings::headerFiles) {
//			newArgs.addAll("-include", header.path.replace("\\", "\\\\")) }
//		
//		test.run(newArgs)
//	}
//	
//	
//	
//	def static FileRecord reconfigureFileList (File currentFile, (String)=>Test test) {
//		
//		flushConsole
//		Settings::consolePS.flush
//		
//		val rootFileRecord = new FileRecord("", "", true, true, 0)
//		val BufferedReader brin = new BufferedReader(new FileReader(Settings::fileList.path))
//		
//		brin.lines.sorted.forEach[
//			
//			if (processedFiles < Settings::maxProcessedFiles)
//			{
//				processedFiles++
//				var path = ""
//				var fileRecord = rootFileRecord
//				
//				println('''[«processedFiles»] «it»''')
//				for (String segment : new Path(it).segments) {
////					println("segment: " + segment)
//					path +=  "/" + segment
////					println("path: " + path)
//					val targetPath = Settings::targetFile.path + path
////					println("targetPath: " + targetPath)
//					
//					if (!segment.endsWith(".c")) {
//						val currentPath = path
//						var childRecord = fileRecord.files.findFirst[filename.equals(currentPath)]
//						if (childRecord == null) {
//							childRecord = new FileRecord(path, "", true, true, 0)
//							fileRecord.files.add(childRecord)
//						}
//						fileRecord = childRecord
//					} else {
//					
//						val sourcePath = Settings::sourceFile.path + path
//						
//						println
//						println("source: " + sourcePath)
//						println("target: " + targetPath)
//						
//						flushConsole
//						Settings::consolePS.flush
//						
//						preprocessor.runFile(sourcePath).toString.writeToFile(targetPath)
//						test.apply(targetPath).run
//						
//						val console_log = Settings::consoleBAOS.toString
//						
//						
//						//get errors
//						val errorCount = console_log.split("\\r?\\n").filter[toLowerCase.contains("error")].length
//						
//						
//						
//						
//						var childRecord = new FileRecord(path, console_log, true, false, errorCount)
//						fileRecord.files.add(childRecord)
//						val targetDir = new File(targetPath).parentFile
//						if (!targetDir.exists) targetDir.mkdirs
//					}
//				}
//				println
//			}
//		]
//		
//		return rootFileRecord
//	}
//	
//	
//	
//	
//	
//	def static FileRecord reconfigure (File currentFile, (String)=>Test test) {
//		
//		flushConsole
//		Settings::consolePS.flush
//		
//		val currentFilePath = currentFile.path
//		val currentRelativePath = currentFilePath.relativeTo(Settings::sourceFile.path)
//		val currentTargetPath = Settings::targetFile + currentRelativePath
//		
//		if (currentFile.isDirectory
//			&& (Settings::ignorePattern == null || !Settings::ignorePattern.matcher(currentRelativePath).matches)) {
//			
//			println('''processing directory [«processedFiles+1»] .«currentRelativePath»/''')
//			
//			val targetDir = new File(currentTargetPath)
//			if (!targetDir.exists) targetDir.mkdirs
//			
//			val fileRecord = new FileRecord(currentRelativePath, Settings::consoleBAOS.toString, true, true, 0)
//			
//			currentFile.listFiles.filter[isFile].sort.forEach[
//				if (processedFiles < Settings::maxProcessedFiles) fileRecord.addFile(reconfigure(test)) ]
//			
//			currentFile.listFiles.filter[isDirectory].sort.forEach[
//				if (processedFiles < Settings::maxProcessedFiles) fileRecord.addFile(reconfigure(test)) ]
//			
//			fileRecord.updateFileCount
//			fileRecord.writeHTMLFile(currentTargetPath + ".htm")
//			return fileRecord
//			
//		} else if ((Settings::ignorePattern == null || !Settings::ignorePattern.matcher(currentRelativePath).matches)
//			&& (currentFile.path.endsWith(".c"))) {
//			
//			println('''processing file [«processedFiles+1»] .«currentRelativePath»''')
//			
//			processedFiles++
//
//			val fileRecord = new FileRecord(currentRelativePath, Settings::consoleBAOS.toString, true, false, 0)
//			fileRecord.writeHTMLFile(currentTargetPath + ".htm")
//			return fileRecord
//			
//		} else {
//			
//			if (currentFile.isDirectory) {
//				println('''ignoring directory [«processedFiles+1»] .«currentRelativePath»/''')
//				return new FileRecord(currentRelativePath, Settings::consoleBAOS.toString, false, true, 0)
//			} else {
//				println('''ignoring file [«processedFiles+1»] .«currentRelativePath»''')
//				return new FileRecord(currentRelativePath, Settings::consoleBAOS.toString, false, false, 0)
//			}
//			
//		}
//	}
//	
//	
//	
//	
//	
//	
//	
//	
//	
//	
//	def static void reconfigure2(File currentFile, (String)=>Test test) {
//		val currentRelativePath = currentFile.path.relativeTo(Settings::sourceFile.path)
//		val currentTargetPath = Settings::targetFile + currentRelativePath
//
//		if(currentFile.isDirectory) {
//			val targetDir = new File(currentTargetPath)
//			if (!targetDir.exists) {
//				println('''making directory .«currentRelativePath»''')
//				targetDir.mkdirs
//				summaryln('''| md    |       |       |       |       |       |       |       | .«currentRelativePath»''')
//			}
//			
//			currentFile.listFiles.filter[isFile].sort.forEach[
//				if (processedFiles < Settings::maxProcessedFiles) reconfigure(test) ]
//			currentFile.listFiles.filter[isDirectory].sort.forEach[
//				if (processedFiles < Settings::maxProcessedFiles) reconfigure(test) ]
//		}
//		else {
//			var File oracle = null
//			if(Settings::oracleFile != null) {
//				oracle = new File(currentFile.path.replace(Settings::sourceFile.path, Settings::oracleFile.path) + ".ast")
//			}
//			if (
//				(!Settings::oracleOnly || oracle != null && oracle.exists)
//				&& (currentFile.path.endsWith(".c")/* || currentFile.path.endsWith(".h")*/)
//				&& (Settings::ignorePattern == null || !Settings::ignorePattern.matcher(currentRelativePath).matches)
//			) {
//				println
//				println('''processing file [«processedFiles+1»] .«currentRelativePath»''')
//				flushConsole
//				Settings::consolePS.flush
//				
//				var double startingTime = 0
//				timeAfterParsing = 0
//				var double timeAfterPreprocessing = 0
//				var double timeAfterReconfiguring = 0
//				
//				startingTime = System.nanoTime()
//				timeAfterParsing = 0;
//				preprocessor.runFile(currentFile.path).toString.writeToFile(currentTargetPath)
//				timeAfterPreprocessing = System.nanoTime()
//				test.apply(currentTargetPath).run
//				timeAfterReconfiguring = System.nanoTime()
//				
//				val sum_console = Settings::consoleBAOS.toString
//				val sum_header =
//					if (sum_console.contains("error: header"))		" ERR   "
//					else											" OK    "
//				
//				val sum_parse =
//					if (sum_console.contains("error: parse error")) " ERR   "
//					else ( if (sum_console.contains("Exception")) 	" EXCPT "
//					else 											" OK    ")
//				val sum_check1 =
//					if (sum_console.contains("check: ContainsIf1")) " #if1  "
//					else 											"       "
//				var sum_result =
//					if (sum_console.contains("result: #if")) 			"   #if "
//					else (if (sum_console.contains("result: no#if")) 	" no#if "
//					else 												"   -   ")
//					
//				var sum_oracle =
//					if (sum_console.contains("oracle: pass")) 			" Opass "
//					else (if (sum_console.contains("oracle: fail")) 	" Ofail "
//					else 												" O-    ")
//				
//				// computing milliseconds
//				val String preprocessingEstimate = 
//					if (timeAfterPreprocessing != 0)
//						String.format(" %5.1f ", (timeAfterPreprocessing - startingTime)/ 1000000)
//					else "   -   "
//				val String parsingEstimate = 
//					if (timeAfterParsing != 0)
//						String.format(" %5.1f ", (timeAfterParsing - timeAfterPreprocessing)/ 1000000)
//					else "   -   "
//				val String recofiguringEstimate = 
//					if (timeAfterReconfiguring != 0)
//						String.format(" %5.1f ", (timeAfterReconfiguring - timeAfterParsing)/ 1000000)
//					else "   -   "
//				
//				summaryln('''|«sum_header»|«sum_parse»|«sum_check1»|«sum_oracle»|«sum_result»|«preprocessingEstimate»|«parsingEstimate»|«recofiguringEstimate»| .«currentRelativePath»''')
//				
////				report.addFileRecord(currentRelativePath, sum_console, false, false)
////				sum_console.split("(\r\n|\n)").forEach[line | 
////					if (line.startsWith("error:") || line.startsWith("warning:"))
////						report.addErrorRecord(line, currentRelativePath)]
//				
//				processedFiles++
//			}
//			else {
//				println
//				println('''ignoring file [«processedFiles+1»] .«currentRelativePath»''')
//				//FileUtils.copyFile(file, new File(targetPath))
////				summaryln('''| ig    |       |       |       |       |       |       |       | .«currentRelativePath»''')
//			}
//		}
//	}
//	
//	def static void old_main(String[] args) {
//		Settings::captureOutput
//		println("Reconfigurator START")
//		println("-- Models Team : ITU.dk (2016) --")
//		println
//		
//		try {
//			val (String)=>Test test = [String f | new Test5(f)]
//			
//			if (!Settings::init(args)) throw new Exception("Settings initialization error.");
//			
//			if (Settings::targetFile.isDirectory) {
//				Settings::targetFile.listFiles.forEach[
//					if (it.isDirectory)
//						FileUtils.deleteDirectory(it)
//					else
//						Files.delete(Paths.get(it.path))
////					try {
////					    Files.delete(Paths.get(it.path));
////					} catch (NoSuchFileException x) {
////					    System.err.format("%s: no such" + " file or directory%n", path);
////					} catch (DirectoryNotEmptyException x) {
////					    System.err.format("%s not empty%n", path);
////					} catch (IOException x) {
////					    // File permission problems are caught here.
////					    System.err.println(x);
////					}
//				]
//				}
//			else {
//				if(Settings::targetFile.parentFile.exists) {
//					new File(Settings::targetFile.parent).listFiles()
//						.filter[name.startsWith(Settings::targetFile.name)]
//						.forEach[delete]
//					Settings::reconfigFile.delete
//					Settings::consoleFile.delete
//					Settings::summaryFile.delete
//					Settings::processedFilesReportFile.delete
//					Settings::ignoredFilesReportFile.delete
//					Settings::errorReportFile.delete
//				}
//				Settings::targetFile.parentFile.mkdir
//			}
//			
//			preprocessor = new Preprocessor
//			transformedFeaturemap = preprocessor.mapFeatureAndTransformedFeatureNames
//			report = new Report
//			
//			summaryln('''----------------------------------------------------------------------------------------''')
//			summaryln('''| HEADR | PARSE | CHEK1 | ORACL | #IFS  | ¤prep | ¤pars | ¤reco | FILE -----------------''')
//			summaryln('''----------------------------------------------------------------------------------------''')
//			
//			
//			if (Settings::fileList!=null)
//				reconfigureFileList(Settings::fileList, test).writeAllFiles(Settings::targetFile)
//			else
//				reconfigure(Settings::sourceFile, test)
//			
//			
//			summaryln('''----------------------------------------------------------------------------------------''')
//			
//			println('''writing file     .«Settings::reconfigFile.path.relativeTo(Settings::targetFile.path)»''')
//			preprocessor.writeReconfig(Settings::reconfigFile.path)
//
////			report.writeProcessedFiles(Settings::processedFilesReportFile.path)
////			report.writeIgnoredFiles(Settings::ignoredFilesReportFile.path)
////			report.writeErrors(Settings::errorReportFile.path)
//		} catch (Exception ex) {
//			print(ex)
//		}
//			
//		println
//		println("Reconfigurator DONE")
//		
//		
//		flushConsole
//		
//		
//		Settings::systemOutPS.append(Settings::consoleBAOS.toString)
//		Settings::systemOutPS.flush
//		
//		Settings::summaryBAOS.toString.writeToFile(Settings.summaryFile.path)
//		Settings::systemOutPS.append(Settings::summaryBAOS.toString)
//		Settings::systemOutPS.flush
//	}
//	
//	
//	
//	
//	
//	
//	def static void main(String[] args) {
//		println("Reconfigurator START")
//		println("-- Models Team : ITU.dk (2016) --")
//		println
//		
//		
//		
//		try {
//			
//			if (!Settings::init(args)) throw new Exception("Settings initialization error.");
//			
//			if (Settings::targetFile.isDirectory) {
//				Settings::targetFile.listFiles.forEach[
//					if (it.isDirectory)
//						FileUtils.deleteDirectory(it)
//					else
//						Files.delete(Paths.get(it.path))
////					try {
////					    Files.delete(Paths.get(it.path));
////					} catch (NoSuchFileException x) {
////					    System.err.format("%s: no such" + " file or directory%n", path);
////					} catch (DirectoryNotEmptyException x) {
////					    System.err.format("%s not empty%n", path);
////					} catch (IOException x) {
////					    // File permission problems are caught here.
////					    System.err.println(x);
////					}
//				]
//				}
//			else {
//				if(Settings::targetFile.parentFile.exists) {
//					new File(Settings::targetFile.parent).listFiles()
//						.filter[name.startsWith(Settings::targetFile.name)]
//						.forEach[delete]
//					Settings::reconfigFile.delete
//					Settings::consoleFile.delete
//					Settings::summaryFile.delete
//					Settings::processedFilesReportFile.delete
//					Settings::ignoredFilesReportFile.delete
//					Settings::errorReportFile.delete
//				}
//				Settings::targetFile.parentFile.mkdir
//			}
//			
//			preprocessor = new Preprocessor
//			transformedFeaturemap = preprocessor.mapFeatureAndTransformedFeatureNames
//			report = new Report
//			
//			var runArgs = new ArrayList<String>
//			runArgs.add("-no-exit")
//			runArgs.add("-nobuiltins")
//			runArgs.add("-showErrors")
//			runArgs.add("-nostdinc")
//			
//			for (String defineMacro : Settings.defineMacros) {
//				runArgs.addAll("-D", defineMacro) }
//			for (String undefMacro : Settings::undefMacros) {
//				runArgs.addAll("-U", undefMacro) }
//			for (File include : Settings::systemIncludeFolders) {
//				runArgs.addAll("-isystem", include.path) }
//			for (File include : Settings::includeFolders) {
//				runArgs.addAll("-I", include.path) }
//			for (File header : Settings::headerFiles) {
//				runArgs.addAll("-include", header.path.replace("\\", "\\\\")) }				
//			
//			runArgs.add(Settings::sourceFile.path)
//			
//			val superc = new SuperC
//			superc.run(runArgs)
//			
//			println(superc.outputAST.printAST)
//			
//		} catch (Exception ex) {
//			print(ex)
//		}
//
//		println
//		println("Reconfigurator DONE")		
//	}

	def static ArrayList<String> runArgs() {
		var runArgs = new ArrayList<String>
		runArgs.add("-silent")
		runArgs.add("-no-exit")
		runArgs.add("-nobuiltins")
		runArgs.add("-showErrors")
		runArgs.add("-nostdinc")
		runArgs.add("-saveLayoutTokens")
		
		for (String defineMacro : Settings.defineMacros) {
			runArgs.addAll("-D", defineMacro) }
		for (String undefMacro : Settings::undefMacros) {
			runArgs.addAll("-U", undefMacro) }
//		for (File include : Settings::systemIncludeFolders) {
//			runArgs.addAll("-isystem", include.path) }
		for (File include : Settings::includeFolders) {
			runArgs.addAll("-I", include.path) }
		for (File header : Settings::headerFiles) {
			runArgs.addAll("-include", header.path.replace("\\", "\\\\")) }				
		
		runArgs.add(Settings::targetFile.path)
		
		runArgs
	}

	def static void main(String[] args) {
		println("new Reconfigurator START")
		
		if (!Settings::init(args)) throw new Exception("Settings initialization error.")
		
		Reconfigurator::file = Settings::targetFile.path
		Reconfigurator::errors = new ArrayList<String>
		
		try {
			// Preprocessor
			Reconfigurator::preprocessor = new Preprocessor
			Reconfigurator::transformedFeaturemap = preprocessor.mapFeatureAndTransformedFeatureNames
			Reconfigurator::preprocessor.runFile(Settings::sourceFile.path).toString.writeToFile(Settings::targetFile.path)
			
			// Parser
			val superc = new SuperC
			superc.run(runArgs)
			Reconfigurator::presenceConditionManager = SuperC::outputPCManager
			
			Reconfigurator::errors.addAll(SuperC::outputErrors)
			
			SuperC::outputFullContent.writeToFile(Settings::targetFile.path + ".full.c")
			
			if (SuperC::outputAST != null) {
				var Node node = SuperC::outputAST
				
				if (Settings::printIntermediaryFiles) {
					node.printAST.writeToFile(Settings::targetFile.path + ".0.parse.ast")
					node.printCode.writeToFile(Settings::targetFile.path + ".0.parse.c")
				}
				
				node = new TxRemActions().transform(node)
				
				if (Settings::printIntermediaryFiles) {
					node.printAST.writeToFile(Settings::targetFile.path + ".1.remact.ast")
					node.printCode.writeToFile(Settings::targetFile.path + ".1.remact.c")
				}
				
				node = new TxMain().transform(node)

				if (Settings::printIntermediaryFiles) {
					node.printAST.writeToFile(Settings::targetFile.path + ".2.txd.ast")
					node.printCode.writeToFile(Settings::targetFile.path)
					
				}
			} else {
				throw new Exception("Reconfigurator no AST")
			}
		} catch (Exception e) {
			Reconfigurator::errors.add("Exception: " + e.message + "\n"
				+ "at: " + e.stackTrace.map[t | t.toString].join("\nat: ") )
		}
		
		println("new Reconfigurator END")
	}

}

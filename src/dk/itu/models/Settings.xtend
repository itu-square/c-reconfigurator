package dk.itu.models

import java.io.File
import java.util.ArrayList
import java.util.List

class Settings {
	
//	static public var boolean oracleOnly = false
	static public var boolean printDebugInfo = false
	static public var boolean printIncludes = false
	static public var boolean reconfigureIncludes = false
	static public var boolean minimize = true
	static public var boolean parseOnly = false
	static public var boolean printFullContent = false
	
	static public var boolean printIntermediaryFiles = false
	
//	static public var int maxProcessedFiles = 10
//	
	static public var String reconfiguratorIncludePlaceholder = "_reconfig_include";
	static public var String reconfiguratorIncludePlaceholderEnd = "_reconfig_include_end";
	static public var List<String> defineMacros
	static public var List<String> undefMacros
	
	static public var File sourceFile
//	static public var File fileList
	static public var File targetFile
	static public var File oracleFile
	static public var List<File> includeFolders
//	static public var List<File> systemIncludeFolders
	static public var List<File> headerFiles
	static public var File reconfigFile
//	static public var File consoleFile
//	static public var File summaryFile
//	static public var File processedFilesReportFile
//	static public var File ignoredFilesReportFile
//	static public var File errorReportFile
//	
//	static public var Pattern ignorePattern
//	
//	static public var systemOutPS = System.out
//	
//	static public var consoleBAOS = new ByteArrayOutputStream()
//	static public var consolePS = new PrintStream(consoleBAOS)
//	
//	static public var summaryBAOS = new ByteArrayOutputStream()
//	static public var summaryPS = new PrintStream(summaryBAOS)
//	
//	
//	static public def void captureOutput() {
//		System.setOut(consolePS)
//		System.setErr(consolePS)
//	}
//	
//	// Reads the command line arguments and processes them into settings.
//	// return false in case of error
//	//        true in case of success
	static public def boolean init(String[] args) {
//		systemIncludeFolders = new ArrayList<File>
		includeFolders = new ArrayList<File>
		headerFiles = new ArrayList<File>
		defineMacros = new ArrayList<String>
		undefMacros = new ArrayList<String>
		
		if(!args.contains("-source")) { println("-source argument is missing."); return false }
		if(!args.contains("-target")) { println("-target argument is missing."); return false }
		
		for (var i = 0; i < args.size; i++) {
			switch(args.get(i)) {
				case "-source":
					if(i < args.size-1) { sourceFile = new File(args.get(i+1)) }
					else {println("-source argument has no value."); return false}
				case "-target":
					if(i < args.size-1) { targetFile = new File(args.get(i+1)) }
					else {println("-target argument has no value."); return false}
				case "-oracle":
					if(i < args.size-1) { oracleFile = new File(args.get(i+1)) }
					else {println("-oracle argument has no value."); return false}
//				case "-isystem":
//					if(i < args.size-1) { systemIncludeFolders.add(new File(args.get(i+1))) }
//					else {println("-isystem argument has no value."); return false}
				case "-I":
					if(i < args.size-1) { includeFolders.add(new File(args.get(i+1))) }
					else {println("-I argument has no value."); return false}
				case "-include":
					if(i < args.size-1) { headerFiles.add(new File(args.get(i+1))) }
					else {println("-include argument has no value."); return false}
				case "-define":
					if(i < args.size-1) { defineMacros.add(args.get(i+1)) }
					else {println("-define argument has no value."); return false}
				case "-undef":
					if(i < args.size-1) { undefMacros.add(args.get(i+1)) }
					else {println("-undef argument has no value."); return false}
//				case "-oracleOnly":
//					oracleOnly = true
				case "-printIncludes":
					printIncludes = true
				case "-reconfigureIncludes":
					reconfigureIncludes = true
				case "-parseOnly":
					parseOnly = true
				case "-printFullContent":
					printFullContent = true
				case "-printIntermediaryFiles":
					printIntermediaryFiles = true
				case "-printDebugInfo":
					printDebugInfo = true
//				case "-fileList":
//					if(i < args.size-1) { fileList = new File(args.get(i+1)) }
//					else {println("-fileList argument has no value."); return false}
//				case "-ignore":
//					if(i < args.size-1) { ignorePattern = Pattern.compile(args.get(i+1), Pattern.CASE_INSENSITIVE) }
//					else {println("-ignore argument has no value."); return false}
			}}
//		
		reconfigFile = new File((if(targetFile.isDirectory) {targetFile} else {targetFile.parent}) + File.separator + "REconfig.c")
//		consoleFile = new File((if(targetFile.isDirectory) {targetFile} else {targetFile.parent}) + File.separator + "REconsole.txt")
//		summaryFile = new File((if(targetFile.isDirectory) {targetFile} else {targetFile.parent}) + File.separator + "REsummary.txt")
//		processedFilesReportFile = new File((if(targetFile.isDirectory) {targetFile} else {targetFile.parent}) + File.separator + "REProcessedFilesReport.htm")
//		ignoredFilesReportFile = new File((if(targetFile.isDirectory) {targetFile} else {targetFile.parent}) + File.separator + "REIgnoredFilesReport.htm")
//		errorReportFile = new File((if(targetFile.isDirectory) {targetFile} else {targetFile.parent}) + File.separator + "REErrorReport.htm")
//		
//		println('''  Source: «sourceFile»''')
//		println('''  Target: «targetFile»''')
//		println('''  Oracle: «if (oracleFile != null) oracleFile else "[none]"»''')
//		systemIncludeFolders.forEach[
//			println(''' ISystem: «it»''')]
//		includeFolders.forEach[
//			println(''' Include: «it»''')]
//		headerFiles.forEach[
//			println(''' Header: «it»''')]
//		println('''REconfig: «reconfigFile»''')
//		println
//		
//		if(sourceFile.isDirectory && targetFile.exists && targetFile.isFile) { println("Source is directory, but target is file."); return false }
//		if(sourceFile.isDirectory && oracleFile != null && oracleFile.exists && oracleFile.isFile) { println("Source is directory, but oracle is file."); return false }
//		
//		if(sourceFile.isFile && targetFile.exists && targetFile.isDirectory && fileList==null) { println("Source is file, but target is directory."); return false }
//		if(sourceFile.isFile && oracleFile != null && oracleFile.exists && oracleFile.isDirectory && fileList==null) { println("Source is file, but oracle is directory."); return false }
//
//		if (!systemIncludeFolders.forall[if(!exists || !directory) { println("ISystem does not exist or is not directory: " + it); false} else true])
//			return false
//		if (!includeFolders.forall[if(!exists || !directory) { println("Include does not exist or is not directory: " + it); false} else true])
//			return false
////		if (!headerFiles.forall[if(!exists || directory) { println("Header does not exist or is directory: " + it); false} else true])
////			return false
//		
		true
	}
}
package dk.itu.models

import java.io.File
import java.util.List
import java.util.ArrayList
import java.io.ByteArrayOutputStream
import java.io.PrintStream
import static extension dk.itu.models.Extensions.*

class Settings {
	
	static public var File sourceFile
	static public var File targetFile
	static public var File oracleFile
	static public var List<File> includeFiles
	static public var File reconfigFile
	static public var File outputFile
	
	
	static public var systemOutPS = System.out
	
	static public var consoleBAOS = new ByteArrayOutputStream()
	static public var consolePS = new PrintStream(consoleBAOS)
	
	
	static public def void captureOutput() {
		System.setOut(consolePS)
		System.setErr(consolePS)
	}
	
	// Reads the command line arguments and processes them into settings.
	// return false in case of error
	//        true in case of success
	static public def boolean init(String[] args) {
		includeFiles = new ArrayList<File>
		
		if(!args.contains("-source")) { println("-source argument is missing."); return false }
		if(!args.contains("-target")) { println("-target argument is missing."); return false }
		
		args.filter[it.startsWith("-")].forall[
			switch(it) {
				case "-source":
					if(args.indexOf(it) < args.size-1) { sourceFile = new File(args.get(args.indexOf(it)+1)); return true }
					else {println("-source argument has no value."); return false}
				case "-target":
					if(args.indexOf(it) < args.size-1) { targetFile = new File(args.get(args.indexOf(it)+1)); return true }
					else {println("-target argument has no value."); return false}
				case "-oracle":
					if(args.indexOf(it) < args.size-1) { oracleFile = new File(args.get(args.indexOf(it)+1)); return true }
					else {println("-oracle argument has no value."); return false}
				case "-include":
					if(args.indexOf(it) < args.size-1) { includeFiles.add(new File(args.get(args.indexOf(it)+1))); return true }
					else {println("-include argument has no value."); return false}
				default:
					return true }]
		
		reconfigFile = new File((if(sourceFile.isDirectory) {targetFile} else {targetFile.parent}) + File.separator + "REconfig.c")
		outputFile = new File((if(sourceFile.isDirectory) {targetFile} else {targetFile.parent}) + File.separator + "REoutput.txt")
		
		println('''  Source: «sourceFile»''')
		println('''  Target: «targetFile»''')
		println('''  Oracle: «if (oracleFile != null) oracleFile else "[none]"»''')
		includeFiles.forEach[
			println(''' Include: «it»''')]
		println('''REconfig: «reconfigFile»''')
		println
		
		if(sourceFile.isDirectory && targetFile.exists && targetFile.isFile) { println("Source is directory, but target is file."); return false }
		if(sourceFile.isDirectory && oracleFile != null && oracleFile.exists && oracleFile.isFile) { println("Source is directory, but oracle is file."); return false }
		
		if(sourceFile.isFile && targetFile.exists && targetFile.isDirectory) { println("Source is file, but target is directory."); return false }
		if(sourceFile.isFile && oracleFile != null && oracleFile.exists && oracleFile.isDirectory) { println("Source is file, but oracle is directory."); return false }

		if (!includeFiles.forall[if(!exists || !directory) { println("Include does not exist or is not directory: " + it); false} else true])
			return false
		
		true
	}
}
package dk.itu.models

import java.io.File
import java.util.List
import java.util.ArrayList

class Settings {
	
	static public var File source
	static public var File target
	static public var File oracle
	static public var List<File> includes
	static public var File reconfig
	
	// Reads the command line arguments and processes them into settings.
	// return false in case of error
	//        true in case of success
	static public def boolean init(String[] args) {
		includes = new ArrayList<File>
		
		if(!args.contains("-source")) { println("-source argument is missing."); return false }
		if(!args.contains("-target")) { println("-target argument is missing."); return false }
		
		args.filter[it.startsWith("-")].forall[
			switch(it) {
				case "-source":
					if(args.indexOf(it) < args.size-1) { Settings::source = new File(args.get(args.indexOf(it)+1)); return true }
					else {println("-source argument has no value."); return false}
				case "-target":
					if(args.indexOf(it) < args.size-1) { Settings::target = new File(args.get(args.indexOf(it)+1)); return true }
					else {println("-target argument has no value."); return false}
				case "-oracle":
					if(args.indexOf(it) < args.size-1) { Settings::oracle = new File(args.get(args.indexOf(it)+1)); return true }
					else {println("-oracle argument has no value."); return false}
				case "-include":
					if(args.indexOf(it) < args.size-1) { Settings::includes.add(new File(args.get(args.indexOf(it)+1))); return true }
					else {println("-include argument has no value."); return false}
				default:
					return true }]
		
		reconfig = new File((if(Settings::target.isDirectory) {Settings::target} else {Settings::target.parent}) + "\\REconfig.c")
		
		println('''  Source: «Settings::source»''')
		println('''  Target: «Settings::target»''')
		println('''  Oracle: «Settings::oracle»''')
		includes.forEach[
			println(''' Include: «it»''')]
		println('''REconfig: «Settings::reconfig»''')
		println
	
//		println(Settings::source == null)
//		println(Settings::target == null)
//		println(Settings::oracle == null)
		
		if(Settings::source.isDirectory && Settings::target.exists && Settings::target.isFile) { println("Source is directory, but target is file."); return false }
		if(Settings::source.isDirectory && Settings::oracle.exists && Settings::oracle.isFile) { println("Source is directory, but oracle is file."); return false }
		
		if(Settings::source.isFile && Settings::target.exists && Settings::target.isDirectory) { println("Source is file, but target is directory."); return false }
		if(Settings::source.isFile && Settings::oracle.exists && Settings::oracle.isDirectory) { println("Source is file, but oracle is directory."); return false }

		if (!includes.forall[if(!exists || !directory) { println("Source is file, but oracle is directory."); false} else true])
			return false
		
		true
	}
}
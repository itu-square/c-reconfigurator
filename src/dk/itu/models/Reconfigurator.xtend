package dk.itu.models

import dk.itu.models.preprocessor.Preprocessor
import dk.itu.models.reporting.ErrorRecord
import dk.itu.models.reporting.Report
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
	
	static public var String file
	static public var PresenceConditionManager presenceConditionManager
	static public var Map<String, String> transformedFeaturemap
	static public var Preprocessor preprocessor
	static public var ArrayList<String> errors
	
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
		for (File include : Settings::systemIncludeFolders) {
			runArgs.addAll("-isystem", include.path) }
		for (File include : Settings::includeFolders) {
			runArgs.addAll("-I", include.path) }
		for (File header : Settings::headerFiles) {
			runArgs.addAll("-include", header.path.replace("\\", "\\\\")) }				
		
		if (Settings::runPreprocessor)
			runArgs.add(Settings::targetFile.path)
		else
			runArgs.add(Settings::sourceFile.path)
		
		runArgs
	}

	def static void main(String[] args) {
		println("new Reconfigurator START")
		
		if (!Settings::init(args)) throw new Exception("Settings initialization error.")
		
		Reconfigurator::file = Settings::targetFile.path
		Reconfigurator::errors = new ArrayList<String>
		
		try {
			// Preprocessor
			if (Settings::runPreprocessor) {
				Reconfigurator::preprocessor = new Preprocessor
				Reconfigurator::transformedFeaturemap = preprocessor.mapFeatureAndTransformedFeatureNames
				val preproc = Reconfigurator::preprocessor.runFile(Settings::sourceFile.path).toString
				preproc.writeToFile(Settings::targetFile.path)
				
				if (Settings::printIntermediaryFiles) {
					preproc.writeToFile(Settings::targetFile.path + ".preproc.c")
				}
			}
			
			// Parser
			val superc = new SuperC
			superc.run(runArgs)
			Reconfigurator::presenceConditionManager = SuperC::outputPCManager
			
			Reconfigurator::errors.addAll(SuperC::outputErrors)
			
			if (Settings::printFullContent)
				SuperC::outputFullContent.writeToFile(Settings::targetFile.path + ".full.c")
			
			if (SuperC::outputAST !== null) {
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

				node.printAST.writeToFile(Settings::targetFile.path + ".ast")
				
				if (Settings::runPreprocessor) {
					val sb = new StringBuilder
					if (!Settings::parseOnly) {
						preprocessor.transformedFeatureNames.forEach[
							sb.append("int " + it + ";\n")
						]
						sb.append("\n")
					}
					sb.append(node.printCode)
					sb.toString.writeToFile(Settings::targetFile.path)
				} else {
//					println
//					println("_______________________________________________");
//					for (var i = 0; i < Reconfigurator::presenceConditionManager.variableManager.size; i++)
//						println(Reconfigurator::presenceConditionManager.variableManager.getName(i))
//					println('''total variables [«Reconfigurator::presenceConditionManager.variableManager.size»]''')
//					
//					println("-----------------------------------------------")
//					println
				}
								
				// check oracle
				if(Settings::oracleFile !== null) {
					if(Settings::oracleFile.exists) {
						if(!node.printAST.equals(readFile(Settings::oracleFile.path))) {
							Reconfigurator::errors.add("oracle: fail")
						}
					} else {
						Reconfigurator::errors.add("oracle: !ext")
					}
				} else {
					Reconfigurator::errors.add("oracle: null")
				}
			} else {
				throw new Exception("Reconfigurator no AST")
			}
		} catch (Exception e) {
			Reconfigurator::errors.add("Exception: " + e.message + "\n"
				+ "at: " + e.stackTrace.map[t | t.toString].join("\nat: ") )
		}
		
		val errors = new ArrayList<ErrorRecord>
		Reconfigurator::errors.forEach[
			errors.add(new ErrorRecord(it))
		]
		val report = new Report
		report.addFile(Settings::sourceFile.name, errors)
		report.printSummary
		
		println("new Reconfigurator END")
	}

}

package dk.itu.models.tests

import dk.itu.models.Reconfigurator
import dk.itu.models.reporting.ErrorRecord
import dk.itu.models.reporting.Report
import java.io.File
import java.util.ArrayList

import static extension dk.itu.models.Extensions.*

class FileTest {
	
	
	def static void main(String[] args) { 
		
		println("Begin File Test")
		
		val report = new Report
		val source = new File("/home/alex/reconfigurator/c-reconfigurator-busybox-test/source")
		
		val currentFilePath   = "/home/alex/reconfigurator/test/source/typedef_struct_var1.c"
		val currentTargetPath = "/home/alex/reconfigurator/test/target/typedef_struct_var1.c"
		val currentOraclePath = "/home/alex/reconfigurator/test/oracle/typedef_struct_var1.c"
		
		val currentRelativePath = currentFilePath.relativeTo(source.path)
		
		var runArgs = new ArrayList<String>
			
			runArgs.addAll(
				 "-source"	,currentFilePath
				,"-root"	,source.path
				,"-target"	,currentTargetPath
				,"-oracle"	,currentOraclePath
				,"-include"	,source.path + "/busybox/gcc_predefines.h"
				,"-include"	,source.path + "/busybox/config.h"
				,"-I"		,source.path + "/busybox/include/"
				,"-isystem"	,source.path + "/usr/lib/gcc/x86_64-linux-gnu/5/include"
				,"-isystem"	,source.path + "/usr/lib/gcc/x86_64-linux-gnu/5/include-fixed"
				,"-isystem"	,source.path + "/usr/include/x86_64-linux-gnu"
				,"-isystem"	,source.path + "/usr/include"
				
				,"-reconfigureIncludes"
				,"-printIncludes"
//				,"-printIntermediaryFiles"
//				,"-printFullContent"
//				,"-printDebugInfo"
				)
			
			Reconfigurator::main(runArgs)
			val errors = new ArrayList<ErrorRecord>
			Reconfigurator::errors.forEach[
				println(it)
				errors.add(new ErrorRecord(it))
			]
			report.addFile(currentRelativePath, errors)
		
		
		
		println("End File Test")
		
	}
}
package dk.itu.models.tests

import dk.itu.models.Reconfigurator
import dk.itu.models.reporting.ErrorRecord
import dk.itu.models.reporting.Report
import java.io.File
import java.util.ArrayList

import static extension dk.itu.models.Extensions.*

class TestFiles {
	
	static val report = new Report
	static val source = new File("/home/alex/vbdb/source")
	static val target = new File("/home/alex/vbdb/target")
	static val oracle = new File("/home/alex/vbdb/oracle")
	
	static def void process (File currentFile) {

		val currentFilePath = currentFile.path
		val currentRelativePath = currentFilePath.relativeTo(source.path)
		val currentTargetPath = target + currentRelativePath
		val currentOraclePath = oracle + currentRelativePath
		
		if (currentFile.isDirectory) {
			
			println('''processing directory .«currentRelativePath»/''')
			report.addFolder(currentRelativePath)
			
			val targetDir = new File(currentTargetPath)
			if (!targetDir.exists) targetDir.mkdirs
			
			currentFile.listFiles.filter[isFile].sort.forEach[process(it)]
			
			currentFile.listFiles.filter[isDirectory].sort.forEach[process(it)]

		} else if(currentFilePath.endsWith(".c")) {
			
			println
			println("----------------------------------------------------------------------")
			println('''processing file .«currentRelativePath»''')

			var runArgs = new ArrayList<String>
		
			runArgs.addAll(
				 "-source",	 currentFilePath
				,"-target",  currentTargetPath
				,"-oracle",  currentOraclePath
//				,"-I",       "/home/alex/linux_kernel/linux-4.7/include"
//				,"-I",       "/home/alex/linux_kernel/linux-4.7/arch/x86/include"
//				,"-I",       "/home/alex/linux_kernel/linux-4.7/arch/x86/include/generated/uapi" 
//				,"-I",       "/home/alex/linux_kernel/linux-4.7/arch/x86/include/generated"
//				,"-I",       "/home/alex/linux_kernel/linux-4.7/arch/x86/include/uapi"
//				,"-I",       "/home/alex/linux_kernel/linux-4.7/arch/x86/include/generated/uapi" 
//				,"-I",       "/home/alex/linux_kernel/linux-4.7/include/uapi"
//				,"-I",       "/home/alex/linux_kernel/linux-4.7/include/generated/uapi"
//				,"-include", "test.h"
//				,"-printIntermediaryFiles"
//				,"-printDebugInfo"
				)
			
			Reconfigurator::main(runArgs)
			val errors = new ArrayList<ErrorRecord>
			Reconfigurator::errors.forEach[
				println(it)
				errors.add(new ErrorRecord(it))
			]
			report.addFile(currentRelativePath, errors)
			
		} else {
			// ignore
		}
	}

	static def void main(String[] args) { 
		
		println("Begin TestFiles")
		
		process(source)
		
		println("Printing Summary")
		
		report.printSummary
		
		println("End TestFiles")
		
	}
}
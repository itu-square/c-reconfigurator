package dk.itu.models.tests

import dk.itu.models.Reconfigurator
import dk.itu.models.reporting.Report
import java.io.File
import java.util.ArrayList

import static extension dk.itu.models.Extensions.*
import dk.itu.models.reporting.ErrorRecord

class LinuxTest {
	
	static val Report report = new Report
	
	def static void process (File currentFile, File sourceRoot, File targetRoot) {
		
		val currentFilePath = currentFile.path
		val currentRelativePath = currentFilePath.relativeTo(sourceRoot.path)
		val currentTargetPath = targetRoot + currentRelativePath
//		
		if (currentFile.isDirectory) {
//			&& (Settings::ignorePattern == null || !Settings::ignorePattern.matcher(currentRelativePath).matches)) {
			
//			println('''processing directory [«processedFiles+1»] .«currentRelativePath»/''')
//			
			val targetDir = new File(currentTargetPath)
			if (!targetDir.exists) targetDir.mkdirs
			
//			val fileRecord = new FileRecord(currentRelativePath, Settings::consoleBAOS.toString, true, true, 0)
//			
			currentFile.listFiles.filter[isFile].sort.forEach[process(it,sourceRoot,targetRoot)]
//				if (processedFiles < Settings::maxProcessedFiles) fileRecord.addFile(reconfigure(test)) ]
//			
			currentFile.listFiles.filter[isDirectory].sort.forEach[process(it,sourceRoot,targetRoot)]
//				if (processedFiles < Settings::maxProcessedFiles) fileRecord.addFile(reconfigure(test)) ]

			report.addFolder(currentRelativePath)
						
//			fileRecord.updateFileCount
//			fileRecord.writeHTMLFile(currentTargetPath + ".htm")
//			return fileRecord
//			
		} else if (currentFile.path.endsWith(".c")) {
//			&& (Settings::ignorePattern == null || !Settings::ignorePattern.matcher(currentRelativePath).matches)
//			) {
//			
			println('''processing file .«currentRelativePath»''')

			var runArgs = new ArrayList<String>
		
			runArgs.addAll(
				 "-source",	 currentFilePath
				,"-target",  currentTargetPath
//				,"-I",       "/home/alex/linux_kernel/linux-4.7/include"
//				,"-I",       "/home/alex/linux_kernel/linux-4.7/arch/x86/include"
//				,"-I",       "/home/alex/linux_kernel/linux-4.7/arch/x86/include/generated/uapi" 
//				,"-I",       "/home/alex/linux_kernel/linux-4.7/arch/x86/include/generated"
//				,"-I",       "/home/alex/linux_kernel/linux-4.7/arch/x86/include/uapi"
//				,"-I",       "/home/alex/linux_kernel/linux-4.7/arch/x86/include/generated/uapi" 
//				,"-I",       "/home/alex/linux_kernel/linux-4.7/include/uapi"
//				,"-I",       "/home/alex/linux_kernel/linux-4.7/include/generated/uapi"
				,"-include", "test.h"		
				)
			Reconfigurator::main(runArgs)
			
			val errors = new ArrayList<ErrorRecord>
			Reconfigurator::errors.forEach[errors.add(new ErrorRecord(it))]
			report.addFile(currentRelativePath, errors)

//			fileRecord.writeHTMLFile(currentTargetPath + ".htm")
			
		} else {
			
//			if (currentFile.isDirectory) {
//				println('''ignoring directory [«processedFiles+1»] .«currentRelativePath»/''')
//				return new FileRecord(currentRelativePath, Settings::consoleBAOS.toString, false, true, 0)
//			} else {
//				println('''ignoring file [«processedFiles+1»] .«currentRelativePath»''')
//				return new FileRecord(currentRelativePath, Settings::consoleBAOS.toString, false, false, 0)
//			}
			
		}
	}


	
	def static void main(String[] args) { 
		
		println("Begin LinuxTest")
		
		val source = new File("/home/alex/linux_kernel/linux-4.7/drivers/message")//balloon_compaction.c")
		val target = new File("/home/alex/linux_kernel/linux-4.7-target/drivers/message")//balloon_compaction.c")

		process(source, source, target)
		
		println("all     " + report.fileRecords.size)
		println("files   " + report.fileRecords.filter[!folder].size)
		println("folders " + report.fileRecords.filter[folder].size)
		
		println("OK      " + report.fileRecords
			.filter[!folder && errors.forall[e | !e.error.startsWith("Exception")]].size)
			
			
//		report.fileRecords
//			.filter[!folder]// && errors.forall[e | !e.error.startsWith("error:(1)")]]
//			.forEach[
//			println(filename + " " + errors.size)
//			errors.forEach[println(error)]
//			println
//		]

		report.writeFiles(source, target)
		
		println("End LinuxTest")
		
	}
	
}
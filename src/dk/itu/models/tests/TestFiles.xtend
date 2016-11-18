package dk.itu.models.tests

import dk.itu.models.Reconfigurator
import java.io.File
import java.util.ArrayList

import static extension dk.itu.models.Extensions.*

class TestFiles {
	
	static val source = new File("/home/alex/linux_kernel/test-files")
	static val target = new File("/home/alex/linux_kernel/test-files-target")
	
	static def void process (File currentFile) {

		val currentFilePath = currentFile.path
		val currentRelativePath = currentFilePath.relativeTo(source.path)
		val currentTargetPath = target + currentRelativePath
		
		if (currentFile.isDirectory) {
			
			println('''processing directory .«currentRelativePath»/''')
			
			val targetDir = new File(currentTargetPath)
			if (!targetDir.exists) targetDir.mkdirs
			
			currentFile.listFiles.filter[isFile].sort.forEach[process(it)]
			
			currentFile.listFiles.filter[isDirectory].sort.forEach[process(it)]

		} else if(currentFilePath.endsWith(".c")) {
			
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
//				,"-include", "test.h"
//				,"-printDebugInfo"		
				)
			Reconfigurator::main(runArgs)
			Reconfigurator::errors.forEach[println(it)]
			
		} else {
			// ignore
		}
	}

	static def void main(String[] args) { 
		
		println("Begin TestFiles")
		
		process(source)
		
		println("End TestFiles")
		
	}
}
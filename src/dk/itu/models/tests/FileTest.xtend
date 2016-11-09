package dk.itu.models.tests

import java.util.ArrayList
import dk.itu.models.Reconfigurator

class FileTest {
	
	
	def static void main(String[] args) { 
		
		println("Begin LinuxTest")
		
		val source = "/home/alex/linux_kernel/linux-4.7/"
		val target = "/home/alex/linux_kernel/linux-4.7-target/"
		
		var runArgs = new ArrayList<String>
		
		runArgs.addAll(
			 "-source",	 source + "test.c"
			,"-target",  target + "test.c"
			,"-I",		 source + "include/"
			,"-I",       source + "include/uapi"
			,"-I",		 source + "arch/x86/include/uapi/"
//			,"-I",       "/home/alex/linux_kernel/linux-4.7/include"
//			,"-I",       "/home/alex/linux_kernel/linux-4.7/arch/x86/include"
//			,"-I",       "/home/alex/linux_kernel/linux-4.7/arch/x86/include/generated/uapi" 
//			,"-I",       "/home/alex/linux_kernel/linux-4.7/arch/x86/include/generated"
//			,"-I",       "/home/alex/linux_kernel/linux-4.7/arch/x86/include/generated/uapi" 
//			,"-I",       "/home/alex/linux_kernel/linux-4.7/include/generated/uapi"
//			,"-include", "/home/alex/linux_kernel/linux-4.7/include/linux/mutex.h"
//			,"-include", "/home/alex/linux_kernel/linux-4.7/include/linux/mutex-debug.h"
//			,"-include", "/home/alex/linux_kernel/linux-4.7/include/linux/wait.h"
//			,"-include", "/home/alex/linux_kernel/linux-4.7/include/linux/types.h"
//			,"-include", "/home/alex/linux_kernel/linux-4.7/include/linux/spinlock_types_up.h"
//			,"-include", "/home/alex/linux_kernel/linux-4.7/include/linux/spinlock_types.h"
			,"-define",  "__GNUC__=5"
			,"-define",  "__GNUC_MINOR__=4"
			,"-define",  "__GNUC_PATCHLEVEL__=0"
			,"-undef",   "__INTEL_COMPILER"
			,"-undef",	 "__CHECKER__"
			,"-printFullContent"
			,"-printIntermediaryFiles"
			,"-printIncludes"
			,"-reconfigureIncludes"
			)
		Reconfigurator::main(runArgs)
		
		Reconfigurator::errors.forEach[println(it)]
		
		
		
		println("End LinuxTest")
		
	}
}
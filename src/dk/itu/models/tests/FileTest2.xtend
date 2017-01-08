package dk.itu.models.tests

import java.util.ArrayList
import dk.itu.models.Reconfigurator

class FileTest2 {
	
	
	def static void main(String[] args) { 
		
		println("Begin FileTest2")
		
		var runArgs = new ArrayList<String>
		
		runArgs.addAll(
			 "-source",	"/home/alex/reconfigurator/c-reconfigurator-test/source/libssh/0a4ea19/pki.c"
			,"-target",	"/home/alex/reconfigurator/c-reconfigurator-test/target/libssh/0a4ea19/pki.c"
			,"-oracle",	"/home/alex/reconfigurator/c-reconfigurator-test/oracle/libssh/0a4ea19/pki.c.ast"
			,"-I",		"/home/alex/reconfigurator/c-reconfigurator-test/source/libssh/0a4ea19/incl_reconf"
			,"-reconfigureIncludes"
			
//			 "-source",	"/home/alex/reconfigurator/c-reconfigurator-test/source/vbdb/linux/76baeeb/76baeeb.c"
//			,"-target",	"/home/alex/reconfigurator/c-reconfigurator-test/target/vbdb/linux/76baeeb/76baeeb.c"
//			,"-oracle",	"/home/alex/reconfigurator/c-reconfigurator-test/oracle/vbdb/linux/76baeeb/76baeeb.c.ast"
//			,"-I",		"/home/alex/reconfigurator/c-reconfigurator-test/source/vbdb/linux/76baeeb"
//			,"-reconfigureIncludes"
			)
		Reconfigurator::main(runArgs)
		
		Reconfigurator::errors.forEach[println(it)]
		
		
		
		println("End FileTest2")
		
	}
}
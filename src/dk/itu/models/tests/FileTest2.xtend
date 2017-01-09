package dk.itu.models.tests

import java.util.ArrayList
import dk.itu.models.Reconfigurator

class FileTest2 {
	
	
	def static void main(String[] args) { 
		
		println("Begin FileTest2")
		
		var runArgs = new ArrayList<String>
		
		runArgs.addAll(
			 "-source",	"/home/alex/reconfigurator/c-reconfigurator-test/source/libssh/fadbe80/options.c"
			,"-target",	"/home/alex/reconfigurator/c-reconfigurator-test/target/libssh/fadbe80/options.c"
			,"-oracle",	"/home/alex/reconfigurator/c-reconfigurator-test/oracle/libssh/fadbe80/options.c.ast"
			,"-I",		"/home/alex/reconfigurator/c-reconfigurator-test/source/libssh/fadbe80/incl_reconf"
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
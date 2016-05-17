package dk.itu.models.tests

import dk.itu.models.PrintAST
import dk.itu.models.PrintCode
import java.io.FileOutputStream
import java.io.IOException
import java.io.PrintWriter
import java.util.ArrayList
import java.util.List
import xtc.lang.cpp.SuperC
import xtc.tree.Node
import java.util.HashMap
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import java.io.File
import dk.itu.models.Reconfigurator

abstract class Test {
	
	protected val PRINT_HASH_CODE = true

	protected val String file

	new(String inputFile) {
		this.file = inputFile
		Reconfigurator::file = inputFile
	}

	def void run(List<String> args) {
		var newArgs = new ArrayList<String>
		newArgs.addAll(args)
		newArgs.add(file)
		new SuperC().run(newArgs)
	}

	protected def void writeToFile(String text, String file) {
		try {
			var PrintWriter file_output = new PrintWriter(new FileOutputStream(file));
			file_output.write(text);
			file_output.flush();
			file_output.close();
		} catch (IOException e) {
			System.err.println("Can not recover from the input or output fault");
		}
	}

	protected def folder() {
		file.substring(0, file.lastIndexOf(File.separator) + 1)
	}

	def printCode(Node node) {
		PrintCode::printCode(node)
	}

	def printAST(Node node) {
		PrintAST::printAST(node)
	}

	def printAST(Node node, Boolean printHashCode) {
		PrintAST::printAST(node, printHashCode)
	}
	
	static def String get_id (HashMap<PresenceCondition, String> map, PresenceCondition pc) {
		map.get(map.keySet.findFirst[is(pc)])
	}

	def void transform(Node node)

}
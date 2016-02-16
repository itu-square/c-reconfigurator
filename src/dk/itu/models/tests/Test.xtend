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

abstract class Test {
	
	val protected PRINT_HASH_CODE = true

	val protected String file

	new(String inputFile) {
		this.file = inputFile
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
		file.substring(0, file.lastIndexOf('\\') + 1)
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

	def void transform(Node node)

}
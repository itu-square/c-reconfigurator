package dk.itu.models

import java.util.ArrayList
import xtc.tree.Node

abstract class PrintMethod {

	// a list of all ancestors of the current node
	// various uses (e.g. indentation)
	static protected var ArrayList<Node> ancestors

	// the printing output
	static protected var StringBuilder output

	static def print(StringBuilder builder, Object o) {
		builder.append(o)
	}

	static def println(StringBuilder builder) {
		builder.append("\n")
	}

	static def println(StringBuilder builder, Object o) {
		builder.append(o + "\n")
	}

}
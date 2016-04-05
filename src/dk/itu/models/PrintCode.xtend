package dk.itu.models

import java.util.ArrayList
import xtc.lang.cpp.CTag
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.tree.GNode
import xtc.tree.Node

import static extension dk.itu.models.Extensions.*

class PrintCode extends PrintMethod {

	// the indentation prefix; add or remove spaces from it
	static private var indent = ""

	static private var last_C_line = ""
	static private var last_line = ""

	static private var firstToken = true

	static def String printCode(Object o) {
		indent = ""
		last_C_line = ""
		last_line = ""
		firstToken = true
		ancestors = new ArrayList<Node>
		output = new StringBuilder
		t(o)
		output.toString
	}

	static def private dispatch void t(PresenceCondition condition) {
		val CPPexp = condition.PCtoCPPexp
		
		if (!last_line.empty && !last_line.startsWith("#"))
			output.println

		if (ancestors.last.head == condition) {
			if (!last_line.startsWith("#"))
				output.println
			output.println('''«indent»#if «CPPexp»''')
			last_line = '''#if «CPPexp»'''
		} else {
//			if (ancestors.last.filter(PresenceCondition).size == 2 &&
//				!(ancestors.last.head as PresenceCondition).is(condition)) {
//				output.println('''«indent»#else''')
//				last_line = '''#else'''
//			} else {
				output.println('''«indent»#elif «CPPexp»''')
				last_line = '''#elif «CPPexp»'''
//			}
		}
	}

	static def private dispatch void t(Language<CTag> language) {
		
		if (language.toString.equals("}"))
			indent = indent.substring(4)

		if (last_line.endsWith(";") || language.toString.equals("{") || last_line.endsWith("}") ||
			last_line.endsWith("{"))
			output.println

		if (last_line.startsWith("#") && !last_C_line.endsWith(";") && !last_C_line.endsWith("{") &&
			!last_C_line.endsWith("}")) {
			output.print(last_C_line.replaceAll(".", " "))
		}

		if (last_line.startsWith("#") || last_C_line.endsWith(";") || last_C_line.endsWith("{") ||
			last_C_line.endsWith("}") || language.toString.equals("{"))
			output.print(indent)

		if (firstToken || language.toString.equals(";") || language.toString.equals(")") || last_C_line.endsWith("(") ||
			last_C_line.endsWith(";") || language.toString.equals("{") || last_C_line.endsWith("{") ||
			language.toString.equals("}") || last_C_line.endsWith("}") || last_C_line.endsWith("!")) {
			firstToken = false
		} else {
			output.print(" ")
			last_C_line += " "
		}
		
		if (last_C_line.endsWith("}") && !last_line.startsWith("#")) {
			output.println
		}

		output.print(language.toString)
		if (last_C_line.endsWith(";") || last_C_line.endsWith("{") || last_C_line.endsWith("}"))
			last_C_line = language.toString
		else
			last_C_line += language

		last_line = last_C_line

		if (language.toString == "{")
			indent += "    "
	}

	static def private dispatch void t(GNode node) {
		ancestors.add(node)

//		println('''[DEBUG] node: «node»''')
		node.forEach[
//			println('''[DEBUG] «it»: «it.class»''')
			t(it)
		]

		ancestors.remove(node)

		if (node.name.equals("Conditional")) {
			if (!last_line.startsWith("#"))
				output.println
			output.println('''«indent»#endif''')
			last_line = "#"
			if (last_C_line.endsWith("}") || last_C_line.endsWith(";"))
				output.println
		}
	}
}

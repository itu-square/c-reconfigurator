package dk.itu.models

import java.util.ArrayList
import xtc.lang.cpp.CTag
import xtc.lang.cpp.PresenceConditionManager
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.tree.GNode
import xtc.tree.Node

class TxPrintCode {
	
	// the PresenceConditionManager which was used when building the AST
	// without this it is not possible to access the variable names in the PresenceConditions
	protected val PresenceConditionManager manager
	
	// a list of all ancestors of the current node
	// various uses (e.g. indentation)
	protected val ArrayList<Node> ancestors
	
	// the indentation prefix; add or remove spaces from it
	private var indent = ""
	
	private var last_C_line = ""
	private var last_line = ""
	
	// the printing output
	private var output = new StringBuilder
	
	private var firstToken = true
	
	new(PresenceConditionManager manager) {
		this.manager = manager
    	this.ancestors = new ArrayList<Node>
	}
	
	def transform(Object o) {
		indent = ""
		last_C_line = ""
		last_line = ""
		firstToken = true
		ancestors.clear
		output = new StringBuilder
		t(o)
		output.toString
	}
	
	def print(StringBuilder builder, String string) {
		builder.append(string)
	}
	
	def println(StringBuilder builder) {
		builder.append("\n")
	}
	
	def println(StringBuilder builder, String string) {
		builder.append(string + "\n")
	}
		
	def private dispatch void t(PresenceCondition condition) {
		if(!last_line.empty && !last_line.startsWith("#"))
			output.println
			
		if(ancestors.last.head == condition){
			output.println('''«indent»#if «condition»''')
			last_line = '''#if «condition»'''
			} else {
			if(ancestors.last.filter(PresenceCondition).size == 2 && !(ancestors.last.head as PresenceCondition).is(condition)) {
				output.println('''«indent»#else''')
				last_line = '''#else'''
			} else {
				output.println('''«indent»#elif «condition»''')
				last_line = '''#elif «condition»'''		
			}
		}
	}

	def private dispatch void t(Language<CTag> language) {
		
		if(language.toString.equals("}"))
			indent = indent.substring(4)
		
		if(last_line.endsWith(";") || language.toString.equals("{") || last_line.endsWith("}") || last_line.endsWith("{"))
			output.println
			
		if(last_line.startsWith("#") && !last_C_line.endsWith(";") && !last_C_line.endsWith("{") && !last_C_line.endsWith("}")) {
			output.print(last_C_line.replaceAll(".", " "))
		}
		
		if (last_line.startsWith("#") || last_C_line.endsWith(";") || last_C_line.endsWith("{") || last_C_line.endsWith("}"))
			output.print(indent)
		
		if(firstToken || language.toString.equals(";") || language.toString.equals(")")
			|| last_C_line.endsWith("(") || last_C_line.endsWith(";")
			|| language.toString.equals("{") || last_C_line.endsWith("{")
			|| language.toString.equals("}") || last_C_line.endsWith("}")) {
			firstToken = false
		} else {
			output.print(" ")
			last_C_line += " "
		}
		
		output.print(language.toString)
		if(last_C_line.endsWith(";") || last_C_line.endsWith("{") || last_C_line.endsWith("}"))
			last_C_line = language.toString
		else
			last_C_line += language
		
		last_line = last_C_line
		
		if(language.toString == "{")
			indent += "    "
	}

	def private dispatch void t(GNode node) {
		ancestors.add(node)
		
		node.forEach[t(it)]
		
		ancestors.remove(node)
		
		if(node.name.equals("Conditional")) {
			if(!last_line.startsWith("#"))
				output.println
			output.println('''«indent»#endif''')
			last_line = "#"
		}
	}
}

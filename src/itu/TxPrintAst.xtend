package itu

import java.util.ArrayList
import xtc.lang.cpp.CTag
import xtc.lang.cpp.PresenceConditionManager
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.tree.GNode
import xtc.tree.Node

class TxPrintAst {
	
	// the PresenceConditionManager which was used when building the AST
	// without this it is not possible to access the variable names in the PresenceConditions
	protected val PresenceConditionManager manager
	
	// a list of all ancestors of the current node
	// various uses (e.g. indentation)
	protected val ArrayList<Node> ancestors
	
	// the printing output
	private var output = new StringBuilder

	// setting: enable to print each object's hash code
	val printHashCode = false

	// setting: enable to print each object's type [ pc | lang | gnod ]
	val printType = false


	new(PresenceConditionManager manager) {
		this.manager = manager
    	this.ancestors = new ArrayList<Node>
	}
	
	def transform(Object o) {
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
	
	// compute the indentation prefix of each node
	private def indent(Object node) {
		var ind = ""
		for(var i = 0; i < ancestors.length; i++) {
			if (i != 0 && ancestors.get(i-1).last == ancestors.get(i))
				ind += "   "
			else if (i == 0)
				ind += "   "
			else
				ind += "|  "
		}
		ind
	}
	
	// print object hash
	def hash(Object o) {
		if (printHashCode) ''' («o.hashCode»)''' else ""
	}
	
	// print object type [ pc | lang | gnod ]
	def type(String s) {
		if (printType) s else ""
	}

	def private dispatch void t(PresenceCondition condition) {
		output.println('''«type("[pc  ]")»«indent(condition)»|- «condition»«hash(condition)»''')
	}

	def private dispatch void t(Language<CTag> language) {
		output.println('''«type("[lang]")»«indent(language)»|- «language»«hash(language)»''')
	}

	def private dispatch void t(GNode node) {
		output.println('''«type("[gnod]")»«indent(node)»|- «node.name»«hash(node)»''')
		
		ancestors.add(node)
		
		node.forEach[t(it)]
		
		ancestors.remove(node)
	}

}

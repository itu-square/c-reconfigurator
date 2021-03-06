package dk.itu.models

import java.util.ArrayList
import xtc.lang.cpp.CTag
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.tree.GNode
import xtc.tree.Node

import static extension dk.itu.models.Extensions.*

class PrintAST extends PrintMethod {

	// setting: enable to print each object's hash code
	static var printHashCode = true

	// setting: enable to print each object's type [ pc | lang | gnod ]
	static val printType = false
	
	// setting: enable to print each object's properties
	static val printProps = false

	static def printAST(Object o) {
		printAST(o, false)
	}

	static def printAST(Object o, Boolean setPrintHashCode) {
		ancestors = new ArrayList<Node>
		output = new StringBuilder
		printHashCode = setPrintHashCode
		t(o)
		output.toString
	}

	// compute the indentation prefix of each node
	static private def indent(Object node) {
		var ind = ""
		for (var i = 0; i < ancestors.length; i++) {
			if (i != 0 && ancestors.get(i - 1).last == ancestors.get(i))
				ind += "   "
			else if (i == 0)
				ind += "   "
			else
				ind += "|  "
		}
		ind
	}

	// print object hash
	static def hash(Object o) {
		if (printHashCode) ''' («o.hashCode»)''' else ""
	}

	// print object type [ pc | lang | gnod ]
	static def type(String s) {
		if(printType) s else ""
	}
	
	// print properties
	static def properties(Object o) {
		var String p = ""
		if (printProps && o instanceof Node) {
			p += "[properties: "
			for(property : (o as Node).properties)
				p += property + " "
			p += "]"
		}
		p
	}

	static def private dispatch void t(PresenceCondition condition) {
		val CPPexp = condition.PCtoCPPexp
		
		output.println('''«type("[pc  ]")»«indent(condition)»|- «CPPexp»«hash(condition)»«properties(condition)»''')
	}

	static def private dispatch void t(Language<CTag> language) {
		output.println('''«type("[lang]")»«indent(language)»|- «language.class.canonicalName»<«language.tag»>«language»  «hash(language)»«properties(language)»''')
	}

	static def private dispatch void t(GNode node) {
		
		val locs = node.nestedNodesLocations
		
		if (
			!Settings::printIncludes
			&& ancestors.size >= 1
			&& ancestors.last.name.equals("ExternalDeclarationList")
			&& !locs.contains(Reconfigurator::file)
		) {
			return
		}
		
		output.println('''«type("[gnod]")»«indent(node)»|- «node.name»«hash(node)»«properties(node)»''')

		ancestors.add(node)

		node.forEach[t(it)]

		ancestors.remove(node)
	}

}

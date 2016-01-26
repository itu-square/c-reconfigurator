package itu

import java.util.List
import xtc.lang.cpp.PresenceConditionManager
import xtc.lang.cpp.Syntax.Language
import xtc.tree.GNode
import xtc.tree.Node
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.CTag
import java.io.PrintStream

class TxPrintAst extends Tx {
	private def indent(List<Node> ancestors, Object node) {
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
	
	val printHashCode = false
	def hash(Object o) {
		if (printHashCode) ''' («o.hashCode»)''' else ""
	}
	
	val printType = true
	def type(String s) {
		if (printType) s else ""
	}
	
	private val PrintStream output

	new(PresenceConditionManager manager, PrintStream output) {
		super(manager)
		this.output = output
	}

	override PresenceCondition tx_start(PresenceConditionManager.PresenceCondition condition, List<Node> ancestors) {
		output.println('''«type("[pc  ]")»«indent(ancestors, condition)»|- «condition»«hash(condition)»''')
		manager.newPresenceCondition(condition.BDD)
	}

	override void tx_end(PresenceConditionManager.PresenceCondition condition, List<Node> ancestors) {
		
	}

	override Language<CTag> tx_start(Language<CTag> language, List<Node> ancestors) {
		output.println('''«type("[lang]")»«indent(ancestors, language)»|- «language»«hash(language)»''')
		language.copy
	}

	override void tx_end(Language<CTag> language, List<Node> ancestors) {
		
	}

	override GNode tx_start(GNode node, List<Node> ancestors) {
		output.println('''«type("[gnod]")»«indent(ancestors, node)»|- «node.name»«hash(node)»''')
		val newNode = GNode::create(node.name)
		node.forEach[newNode.add(it)]
		newNode
	}

	override void tx_end(GNode node, List<Node> ancestors) {
		
	}

	override Node tx_start(Node node, List<Node> ancestors) {
		output.println('''«type("[node]")»«indent(ancestors, node)»|- «node»«hash(node)»''')
		val newNode = GNode::create(node.name)
		node.forEach[newNode.add(it)]
		newNode
	}

	override void tx_end(Node node, List<Node> ancestors) {
		
	}

}

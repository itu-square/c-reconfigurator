package itu

import java.util.List
import xtc.lang.cpp.PresenceConditionManager
import xtc.lang.cpp.Syntax.Language
import xtc.tree.GNode
import xtc.tree.Node
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.CTag

class TxPrintAst implements Tx {
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

	val manager = new PresenceConditionManager

	override PresenceCondition tx_start(PresenceConditionManager.PresenceCondition condition, List<Node> ancestors) {
		println('''[pc  ]«indent(ancestors, condition)»|- «condition» («condition.hashCode»)''')
		manager.newPresenceCondition(condition.BDD)
	}

	override void tx_end(PresenceConditionManager.PresenceCondition condition, List<Node> ancestors) {
		
	}

	override Language<CTag> tx_start(Language<CTag> language, List<Node> ancestors) {
		println('''[lang]«indent(ancestors, language)»|- «language» («language.hashCode»)''')
		language.copy
	}

	override void tx_end(Language<CTag> language, List<Node> ancestors) {
		
	}

	override GNode tx_start(GNode node, List<Node> ancestors) {
		println('''[gnod]«indent(ancestors, node)»|- «node.name» («node.hashCode»)''')
		GNode::create(node.name)
	}

	override void tx_end(GNode node, List<Node> ancestors) {
		
	}

	override Node tx_start(Node node, List<Node> ancestors) {
		println('''[node]«indent(ancestors, node)»|- «node» («node.hashCode»)''')
		GNode::create(node.name)
	}

	override void tx_end(Node node, List<Node> ancestors) {
		
	}

}

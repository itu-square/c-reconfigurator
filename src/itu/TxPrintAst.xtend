package itu

import java.util.List
import xtc.lang.cpp.PresenceConditionManager
import xtc.lang.cpp.Syntax.Language
import xtc.tree.GNode
import xtc.tree.Node

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


	override tx_start(PresenceConditionManager.PresenceCondition condition, List<Node> ancestors) {
		System::out.println('''[pc  ]«indent(ancestors, condition)»|- «condition.toString()»'''.toString)
	}

	override tx_end(PresenceConditionManager.PresenceCondition condition, List<Node> ancestors) {
	}

	override tx_start(Language language, List<Node> ancestors) {
		System::out.println('''[lang]«indent(ancestors, language)»|- «language.toString()»'''.toString)
	}

	override tx_end(Language language, List<Node> ancestors) {
	}

	override tx_start(GNode node, List<Node> ancestors) {
		System::out.println('''[gnod]«indent(ancestors, node)»|- «node.name»'''.toString)
	}

	override tx_end(GNode node, List<Node> ancestors) {
	}

	override tx_start(Node node, List<Node> ancestors) {
		System::out.println('''[node]«indent(ancestors, node)»|- «node.toString()»'''.toString)
	}

	override tx_end(Node node, List<Node> ancestors) {
	}

}

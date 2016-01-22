package itu

import xtc.tree.Node
import xtc.tree.GNode
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import java.util.List

class Traverse {

	def static dispatch void t(GNode node, Tx transformation, List<Node> ancestors) {
		transformation.tx_start(node, ancestors)
		ancestors.add(node)
		for (Object n : node) {
			t(n, transformation, ancestors)
		}
		ancestors.remove(node)
		transformation.tx_end(node, ancestors)
	}

	def static dispatch void t(PresenceCondition pc, Tx transformation, List<Node> ancestors) {
		transformation.tx_start(pc, ancestors)
		transformation.tx_end(pc, ancestors)
	}

	def static dispatch void t(Language lang, Tx transformation, List<Node> ancestors) {
		transformation.tx_start(lang, ancestors)
		transformation.tx_end(lang, ancestors)
	}
	
	def static dispatch void t(Node node, Tx transformation, List<Node> ancestors) {
		transformation.tx_start(node, ancestors)
		transformation.tx_end(node, ancestors)
	}

}

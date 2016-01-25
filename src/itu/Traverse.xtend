package itu

import xtc.tree.Node
import xtc.tree.GNode
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import java.util.List
import xtc.lang.cpp.CTag

class Traverse {

	def static dispatch Node t(GNode node, Tx transformation, List<Node> ancestors) {
		val newNode = transformation.tx_start(node, ancestors)
		ancestors.add(node)
		for (Object n : node) {
			newNode.add(t(n, transformation, ancestors))
		}
		ancestors.remove(node)
		transformation.tx_end(node, ancestors)
		return newNode
	}

	def static dispatch PresenceCondition t(PresenceCondition pc, Tx transformation, List<Node> ancestors) {
		val newPc = transformation.tx_start(pc, ancestors)
		transformation.tx_end(pc, ancestors)
		return newPc
	}

	def static dispatch Language<CTag> t(Language<CTag> lang, Tx transformation, List<Node> ancestors) {
		val newLang = transformation.tx_start(lang, ancestors)
		transformation.tx_end(lang, ancestors)
		return newLang
	}
	
	def static dispatch Node t(Node node, Tx transformation, List<Node> ancestors) {
		val newNode = transformation.tx_start(node, ancestors)
		transformation.tx_end(node, ancestors)
		return newNode
	}

}

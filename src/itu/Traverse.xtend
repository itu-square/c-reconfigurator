package itu

import xtc.tree.Node
import xtc.tree.GNode
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import java.util.List
import xtc.lang.cpp.CTag

class Traverse {

	def static dispatch Node t(GNode node, Tx transformation, List<Node> ancestors) {
		val tempNode = transformation.tx_start(node, ancestors)
		val newNode = GNode.create(tempNode.name)
		
		ancestors.add(tempNode)
		for (Object n : tempNode) {
			newNode.add(t(n, transformation, ancestors))
		}
		ancestors.remove(tempNode)
		transformation.tx_end(newNode, ancestors)
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

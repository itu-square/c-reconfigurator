package dk.itu.models.rules.normalize

import xtc.lang.cpp.CTag
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.tree.GNode
import xtc.util.Pair

class ConditionPushDownRule extends dk.itu.models.rules.Rule {
	
	override dispatch PresenceCondition transform(PresenceCondition cond) {
		cond
	}

	override dispatch Language<CTag> transform(Language<CTag> lang) {
		lang
	}

	override dispatch Pair<Object> transform(Pair<Object> pair) {
		if (pair.empty) return pair
		if (!(pair.head instanceof GNode)) return pair
		if (!(pair.head as GNode).name.equals("Conditional")) return pair
		
		val cond = pair.head as GNode
		if (!cond.forall[
			(it instanceof PresenceCondition)
			|| ((it instanceof GNode) && (it as GNode).name.equals("Conditional"))
			]) return pair
		
		var newPair = pair.tail
		for(GNode node : cond.toList.reverseView.filter(GNode)) {
			val pc = cond.findLast[ it instanceof PresenceCondition && cond.indexOf(it) < cond.indexOf(node)] as PresenceCondition
			val newNode = GNode::create("Conditional")
			node.forEach[child |
				if(child instanceof PresenceCondition) {
					newNode.add(pc.and(child))
				} else {
					newNode.add(child)
				}]
			newPair = new Pair(newNode, newPair)
		}
		newPair
	}
	
	override dispatch Object transform(GNode node) {
		node
	}

}
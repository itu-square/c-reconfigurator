package dk.itu.models.rules

import xtc.lang.cpp.CTag
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.tree.GNode
import xtc.util.Pair

class ConditionPushDownRule2 extends Rule {
	
	new() {
		throw new UnsupportedOperationException("TODO: Fix this rule. Decide if it is even useful.")
	}
	
	override dispatch PresenceCondition transform(PresenceCondition cond) {
		cond
	}

	override dispatch Language<CTag> transform(Language<CTag> lang) {
		lang
	}

	override dispatch Pair<Object> transform(Pair<Object> pair) {
		pair
	}
	
	override dispatch Object transform(GNode node) {
//		if(node.name.equals("Conditional")
//			&& node.size == 2
//			&& node.get(1) instanceof GNode
//			&& (
//				(node.get(1) as GNode).name.equals("CompoundStatement")
//				|| (node.get(1) as GNode).name.equals("DeclarationOrStatementList")
//			)) {
//				val newCond = GNode::create("Conditional")
//				newCond.add(node.get(0))
//				(node.get(1) as GNode).forEach[newCond.add(it)]
//				val newNode = GNode::create((node.get(1) as GNode).name)
//				newNode.add(newCond)
//				return newNode
//			}
		node
	}

}
package dk.itu.models.rules.phase1normalize

import dk.itu.models.rules.Rule
import xtc.lang.cpp.CTag
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.tree.GNode
import xtc.util.Pair

class RemEmptyNodesRule extends Rule {
	
	override dispatch PresenceCondition transform(PresenceCondition cond) {
		cond
	}

	override dispatch Language<CTag> transform(Language<CTag> lang) {
		lang
	}

	override dispatch Pair<Object> transform(Pair<Object> pair) {
		if (!pair.empty && pair.head instanceof GNode) {
			val head = pair.head as GNode
			if(head.name.equals("ExpressionOpt") && head.empty) {
				pair.tail
			} else {
				pair
			}
		} else {
			pair
		}
	}
	
	override dispatch Object transform(GNode node) {
		node
	}
	
}
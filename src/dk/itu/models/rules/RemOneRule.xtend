package dk.itu.models.rules

import xtc.lang.cpp.CTag
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.tree.GNode
import xtc.util.Pair

class RemOneRule extends Rule {
	
	override dispatch PresenceCondition transform(PresenceCondition cond) {
		cond
	}

	override dispatch Language<CTag> transform(Language<CTag> lang) {
		lang
	}

	override dispatch Pair<?> transform(Pair<?> pair) {
		if (!(pair.head instanceof GNode)) return pair
		val node = pair.head as GNode
		
		if (node.name.equals("Conditional")
			&& node.filter(PresenceCondition).size == 1
			&& node.get(0).toString.equals("1")) {
				
				var newPair = pair.tail
				for(var index = node.size - 1; index >= 1; index--)
							newPair = new Pair(node.get(index), newPair)
				newPair
			}
			else
				pair
	}
	
	override dispatch Object transform(GNode node) {
		node
	}

}
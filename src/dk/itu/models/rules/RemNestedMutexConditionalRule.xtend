package dk.itu.models.rules

import xtc.lang.cpp.CTag
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.tree.GNode
import xtc.util.Pair

class RemNestedMutexConditionalRule extends Rule {

	override dispatch PresenceCondition transform(PresenceCondition cond) {
		cond
	}

	override dispatch Language<CTag> transform(Language<CTag> lang) {
		lang
	}

	override dispatch Pair<?> transform(Pair<?> pair) {
		if(pair.head instanceof GNode) {
			val node = pair.head as GNode
			
			if (node.name == "Conditional" && node.size == 2) {
				val c = node.get(0) as PresenceCondition
				val g = guard(node) as PresenceCondition
				
				if (g.isMutuallyExclusive(c)) {
					return pair.tail
				}
			}
		}
		
		pair
	}

	override dispatch Object transform(GNode node) {
		node
	}
}
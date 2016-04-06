package dk.itu.models.rules.normalize

import dk.itu.models.rules.Rule
import xtc.lang.cpp.CTag
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.tree.GNode
import xtc.util.Pair
import static extension dk.itu.models.Extensions.*

class RemZeroRule extends Rule {
	
	override dispatch PresenceCondition transform(PresenceCondition cond) {
		cond
	}

	override dispatch Language<CTag> transform(Language<CTag> lang) {
		lang
	}

	override dispatch Pair<Object> transform(Pair<Object> pair) {
		
		if (!pair.empty &&
			pair.head instanceof GNode &&
			(pair.head as GNode).name.equals("Conditional") &&
			(pair.head as GNode).filter(PresenceCondition).size == 1 &&
			((pair.head as GNode).get(0) as PresenceCondition).isFalse
		) {
			return pair.tail
		}
		
		pair
	}
	
	override dispatch Object transform(GNode node) {
		node
	}

}
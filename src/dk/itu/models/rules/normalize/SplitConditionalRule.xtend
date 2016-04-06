package dk.itu.models.rules.normalize

import xtc.lang.cpp.CTag
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.tree.GNode
import xtc.util.Pair
import static extension dk.itu.models.Extensions.*

class SplitConditionalRule extends dk.itu.models.rules.Rule {
	
	override dispatch PresenceCondition transform(PresenceCondition cond) {
		cond
	}

	override dispatch Language<CTag> transform(Language<CTag> lang) {
		lang
	}

	override dispatch Pair<Object> transform(Pair<Object> pair) {
		if(
			!pair.empty &&
			pair.head instanceof GNode &&
			
			(pair.head as GNode).name == "Conditional" &&
			(pair.head as GNode).filter(PresenceCondition).size >= 2
		) {
			var Pair<Object> newPair = Pair.EMPTY
			for (PresenceCondition pc : (pair.head as GNode).filter(PresenceCondition)) {
				newPair = newPair.append(new Pair<Object>(
					GNode::createFromPair("Conditional", pc, (pair.head as GNode).getChildrenGuardedBy(pc))))
			}
			newPair.append(pair.tail)
		} else
			pair
	}

	override dispatch Object transform(GNode node) {
		node
	}
	
}
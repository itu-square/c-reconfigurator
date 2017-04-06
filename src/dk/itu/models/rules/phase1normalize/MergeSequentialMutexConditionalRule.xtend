package dk.itu.models.rules.phase1normalize

import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.lang.cpp.CTag
import xtc.tree.GNode
import xtc.util.Pair
import static extension dk.itu.models.Extensions.*

class MergeSequentialMutexConditionalRule extends dk.itu.models.rules.Rule {
	override dispatch PresenceCondition transform(PresenceCondition cond) {
		cond
	}

	override dispatch Language<CTag> transform(Language<CTag> lang) {
		lang
	}

	override dispatch Pair<Object> transform(Pair<Object> pair) {

		if(
			!pair.empty
			&& pair.size >= 2
			
			&& pair.head.is_GNode("Conditional")
			&& pair.head.as_GNode.filter(PresenceCondition).size.equals(1)
			
			&& pair.tail.head.is_GNode("Conditional")
			&& pair.tail.head.as_GNode.filter(PresenceCondition).size.equals(1)
			
			&& pair.head.as_GNode.filter(PresenceCondition).get(0)
				.isMutuallyExclusive(pair.tail.head.as_GNode.filter(PresenceCondition).get(0))
			&& pair.head.as_GNode.toPair.tail.structurallyEquals(pair.tail.head.as_GNode.toPair.tail)
		) {
			
			return new Pair<Object>(
				GNode::createFromPair(
					"Conditional",
					pair.head.as_GNode.filter(PresenceCondition).get(0)
						.or(pair.tail.head.as_GNode.filter(PresenceCondition).get(0)),
					pair.head.as_GNode.toPair.tail
				)).append(pair.tail.tail)
		}
		
		pair
	}
	
	override dispatch Object transform(GNode node) {
		node
	}
}
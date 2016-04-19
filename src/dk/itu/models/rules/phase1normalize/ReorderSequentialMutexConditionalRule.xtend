package dk.itu.models.rules.phase1normalize

import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.lang.cpp.CTag
import xtc.tree.GNode
import xtc.util.Pair
import static extension dk.itu.models.Extensions.*

class ReorderSequentialMutexConditionalRule extends dk.itu.models.rules.Rule {
	
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
			
			&& (pair.head instanceof GNode)
			&& (pair.head as GNode).name.equals("Conditional")
			&& (pair.head as GNode).filter(PresenceCondition).size.equals(1)
			
			&& (pair.tail.head instanceof GNode)
			&& (pair.tail.head as GNode).name.equals("Conditional")
			&& (pair.tail.head as GNode).filter(PresenceCondition).size.equals(1)
			
			&& (pair.head as GNode).filter(PresenceCondition).get(0)
				.isMutuallyExclusive((pair.tail.head as GNode).filter(PresenceCondition).get(0))
			&& (pair.head as GNode).filter(PresenceCondition).get(0).PCtoCPPexp.length >
				(pair.tail.head as GNode).filter(PresenceCondition).get(0).PCtoCPPexp.length
		) {
			return new Pair<Object>(pair.tail.head).add(pair.head).append(pair.tail.tail)
		}
		
		pair
	}
	
	override dispatch Object transform(GNode node) {
		node
	}
}
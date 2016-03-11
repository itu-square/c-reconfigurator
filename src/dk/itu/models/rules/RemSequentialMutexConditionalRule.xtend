package dk.itu.models.rules

import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.lang.cpp.CTag
import xtc.tree.GNode
import xtc.util.Pair
import static extension dk.itu.models.Extensions.*

class RemSequentialMutexConditionalRule extends Rule {
	override dispatch PresenceCondition transform(PresenceCondition cond) {
		cond
	}

	override dispatch Language<CTag> transform(Language<CTag> lang) {
		lang
	}

	override dispatch Pair<?> transform(Pair<?> pair) {
		pair
	}
	
	override dispatch Object transform(GNode node) {
		if (
			node.name.equals("Conditional") &&
			node.filter(PresenceCondition).size.equals(2) &&
			node.filter(PresenceCondition).get(0).isMutuallyExclusive(node.filter(PresenceCondition).get(1)) ) {

				var pair1 = node.pipe[it | filter[ e | indexOf(e) > indexOf(filter(PresenceCondition).get(0))
													&& indexOf(e) < indexOf(filter(PresenceCondition).get(1))]].toPair
				var pair2 = node.pipe[it | filter[ e | indexOf(e) > indexOf(filter(PresenceCondition).get(1))]].toPair

				if(pair1 == pair2){
					GNode::createFromPair(
						"Conditional",
						node.filter(PresenceCondition).get(0).or(node.filter(PresenceCondition).get(1)),
						pair1)
				} else
					node
		} else
			node
	}
}
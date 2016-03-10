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
		var GNode node
		var Iterable<PresenceCondition> pcs
		
		if (
			pair.head instanceof GNode && !(node = pair.head as GNode).equals(null) &&
			node.name.equals("Conditional") && !(pcs = node.filter(PresenceCondition)).equals(null) &&
			pcs.size.equals(2) && pcs.get(0).isMutuallyExclusive(pcs.get(1)) ) {
//				println(node)
				
				var pair1 = node.pipe[it | filter[ e | indexOf(e) > indexOf(filter(PresenceCondition).get(0))
													&& indexOf(e) < indexOf(filter(PresenceCondition).get(1))]].toPair
				var pair2 = node.pipe[it | filter[ e | indexOf(e) > indexOf(filter(PresenceCondition).get(1))]].toPair

				if(pair1 == pair2){
					Pair.EMPTY.append(pair1 as Pair<Object>).append(pair.tail as Pair<Object>)
				} else
					pair
		} else
			pair
	}
	
	override dispatch Object transform(GNode node) {
		node
	}
}
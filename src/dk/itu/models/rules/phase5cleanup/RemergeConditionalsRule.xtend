package dk.itu.models.rules.phase5cleanup

import xtc.lang.cpp.CTag
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.tree.GNode
import xtc.util.Pair

import static extension dk.itu.models.Extensions.*

class RemergeConditionalsRule extends dk.itu.models.rules.AncestorGuaranteedRule {
	
	override dispatch PresenceCondition transform(PresenceCondition cond) {
		cond
	}

	override dispatch Language<CTag> transform(Language<CTag> lang) {
		lang
	}

	override dispatch Pair<Object> transform(Pair<Object> pair) {
		
		if (
			!pair.empty
			&& pair.size >= 2
			
			&& pair.head.is_GNode("Conditional")
			
			&& pair.tail.head.is_GNode("Conditional")
			&& pair.tail.head.as_GNode.filter(PresenceCondition).size == 1
			
			&& pair.head.as_GNode.filter(PresenceCondition).forall[
				it.isMutuallyExclusive(pair.tail.head.as_GNode.get(0) as PresenceCondition)]
		) {
			return new Pair<Object>(
				GNode::create("Conditional").addAll(
					pair.head.as_GNode.toPair
					.append(pair.tail.head.as_GNode.toPair)
				),
				pair.tail.tail
			)
		}
		pair
	}
	
	override dispatch Object transform(GNode node) {
		node
	}

}
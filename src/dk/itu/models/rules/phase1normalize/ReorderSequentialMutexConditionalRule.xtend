package dk.itu.models.rules.phase1normalize

import dk.itu.models.rules.AncestorGuaranteedRule
import xtc.lang.cpp.CTag
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.tree.GNode
import xtc.util.Pair

import static extension dk.itu.models.Extensions.*

class ReorderSequentialMutexConditionalRule extends AncestorGuaranteedRule {
	
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
			
			&& !ancestors.last.name.equals("ExternalDeclarationList")
			
			&& pair.head.is_GNode("Conditional")
			&& pair.head.as_GNode.filter(PresenceCondition).size.equals(1)
			
			&& pair.tail.head.is_GNode("Conditional")
			&& pair.tail.head.as_GNode.filter(PresenceCondition).size.equals(1)
			
			&& pair.head.as_GNode.filter(PresenceCondition).get(0)
				.isMutuallyExclusive(pair.tail.head.as_GNode.filter(PresenceCondition).get(0))
			&& pair.head.as_GNode.filter(PresenceCondition).get(0).toString.length >
				pair.tail.head.as_GNode.filter(PresenceCondition).get(0).toString.length
		) {
			return new Pair<Object>(pair.tail.head).add(pair.head).append(pair.tail.tail)
		}
		
		pair
	}
	
	override dispatch Object transform(GNode node) {
		node
	}
}
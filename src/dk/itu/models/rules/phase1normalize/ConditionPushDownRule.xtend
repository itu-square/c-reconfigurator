package dk.itu.models.rules.phase1normalize

import xtc.lang.cpp.CTag
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.tree.GNode
import xtc.util.Pair

import static extension dk.itu.models.Extensions.*

class ConditionPushDownRule extends dk.itu.models.rules.Rule {
	
	override dispatch PresenceCondition transform(PresenceCondition cond) {
		cond
	}

	override dispatch Language<CTag> transform(Language<CTag> lang) {
		lang
	}

	override dispatch Pair<Object> transform(Pair<Object> pair) {
		if (
			!pair.empty
			&& pair.head.is_GNode("Conditional")
			&& pair.head.as_GNode.forall[ (it.is_PresenceCondition) || (it.is_GNode("Conditional")) ]
		) {
			pair.head.as_GNode.toList.filter(GNode).map[node |
				GNode::createFromPair(
					"Conditional",
					node.map[child |
						if(child.is_PresenceCondition) { pair.head.as_GNode.pcOf(node).and(child.as_PresenceCondition) }
						else { child }].toPair) as Object
			].toPair.append(pair.tail)
		} else {
			return pair
		}
	}
	
	override dispatch Object transform(GNode node) {
		node
	}
	
	private def pcOf(GNode cond, GNode node) {
		cond.findLast[ it.is_PresenceCondition && cond.indexOf(it) < cond.indexOf(node)].as_PresenceCondition
	}

}
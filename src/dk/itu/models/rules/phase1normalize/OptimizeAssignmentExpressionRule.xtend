package dk.itu.models.rules.phase1normalize

import dk.itu.models.rules.Rule
import dk.itu.models.strategies.TopDownStrategy
import xtc.lang.cpp.CTag
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.tree.GNode
import xtc.util.Pair

import static extension dk.itu.models.Extensions.*

class OptimizeAssignmentExpressionRule extends Rule {
	
	override dispatch PresenceCondition transform(PresenceCondition cond) {
		cond
	}

	override dispatch Language<CTag> transform(Language<CTag> lang) {
		lang
	}

	override dispatch Pair<Object> transform(Pair<Object> pair) {
		
		if (
			!pair.empty
			
			&& pair.head.is_GNode("AssignmentExpression")
		) {
			val asgnExp = pair.head.as_GNode
			val opIndex = asgnExp.indexOf(asgnExp.findFirst[it.is_GNode("AssignmentOperator")])
			val PCs =
				if (opIndex != -1)
					asgnExp.filter[it.is_GNode("Conditional")]
						.map[node | node.as_GNode.get(0).as_PresenceCondition]
				else
					asgnExp.filter[it.is_GNode("Conditional") && asgnExp.indexOf(it) < opIndex]
						.map[node | node.as_GNode.get(0).as_PresenceCondition]
			
			// compute the disjunction of all declaration PCs
			var PresenceCondition disjunctionPC = null
			for (PresenceCondition pc : PCs) {
				disjunctionPC = if (disjunctionPC === null) pc else pc.or(disjunctionPC)
			}
			
			if (PCs.size > 0) {
			
				var newPair = pair.tail
				
				newPair = new Pair<Object>(
					GNode::create(
						"Conditional",
						disjunctionPC.not,
						pair.head),
					newPair
				)
				
				for (PresenceCondition pc : PCs.toList.reverseView) {
					newPair = new Pair<Object>(
						GNode::create(
							"Conditional",
							pc,
							pair.head),
						newPair)	
				}
				
				val tdn = new TopDownStrategy
				tdn.register(new RemOneRule)
				tdn.register(new RemZeroRule)
				tdn.register(new ConstrainNestedConditionalsRule)
				
//				throw new Exception("test this")
			
				return tdn.transform(newPair) as Pair<Object>
			}
		}
		
		pair
	}
	
	override dispatch Object transform(GNode node) {
		node
	}
	
}
package dk.itu.models.rules.phase1normalize

import dk.itu.models.Reconfigurator
import dk.itu.models.rules.AncestorGuaranteedRule
import dk.itu.models.strategies.TopDownStrategy
import xtc.lang.cpp.CTag
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.tree.GNode
import xtc.util.Pair

import static extension dk.itu.models.Extensions.*

class ExtractConditionalFromArrayDeclaratorRule extends AncestorGuaranteedRule {
	
	override dispatch PresenceCondition transform(PresenceCondition cond) {
		cond
	}

	override dispatch Language<CTag> transform(Language<CTag> lang) {
		lang
	}

	override dispatch Pair<Object> transform(Pair<Object> pair) {
		pair
	}
	
	override dispatch Object transform(GNode node) {
		val arrayDeclarator = node.getDescendantNode("ArrayDeclarator")
		val pcs = node.firstNestedPCs
		
		if (
			node.name.equals("Declaration")
			&& arrayDeclarator != null
			&& (
				!ancestors.exists[anc | anc.name.equals("FunctionDefinition")]
				|| node.getDescendantNode("InitializerOpt") == null)
			&& pcs.size != 0
			&& !(pcs.size == 1 && pcs.get(0).isTrue)
		) {
			var newNode = GNode::create("Conditional")
			var disjPC = Reconfigurator::presenceConditionManager.newPresenceCondition(false)
			
			for (PresenceCondition pc : pcs) {
				newNode = newNode.add(pc).add(GNode::createFromPair("Declaration", node.toPair)).as_GNode
				disjPC = disjPC.or(pc)
			}
			newNode = newNode.add(disjPC.not).add(GNode::createFromPair("Declaration", node.toPair)).as_GNode
				
			val tdn1 = new TopDownStrategy
			tdn1.register(new RemOneRule)
			tdn1.register(new RemZeroRule)
			tdn1.register(new SplitConditionalRule)
			tdn1.register(new ConstrainNestedConditionalsRule)
			newNode = tdn1.transform(newNode).as_GNode
			
			newNode
		} else {
			node
		}
	}
	
}
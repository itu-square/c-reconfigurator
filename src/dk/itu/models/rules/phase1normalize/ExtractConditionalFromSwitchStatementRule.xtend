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

class ExtractConditionalFromSwitchStatementRule extends AncestorGuaranteedRule {
	
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
		
		if (
			node.name.equals("SelectionStatement")
			&& (node.get(0) instanceof Language<?>)
			&& (node.get(0) as Language<CTag>).tag.equals(CTag::SWITCH)
		) {
			val declarationOrStatementList = node.getDescendantNode("DeclarationOrStatementList").as_GNode
			
			if (
				declarationOrStatementList !== null
				&& declarationOrStatementList.filter[it.is_GNode("Conditional")].size > 0
			) {
				
				val pcs = (declarationOrStatementList.findFirst[it.is_GNode("Conditional")].as_GNode).filter(PresenceCondition)
				
				var newNode = GNode::create("Conditional")
				
				var disjPC = Reconfigurator::presenceConditionManager.newPresenceCondition(false)
				for (PresenceCondition pc : pcs) {
					newNode = newNode.add(pc).add(GNode::createFromPair("SelectionStatement", node.toPair)).as_GNode
					disjPC = disjPC.or(pc)
				}
				
				newNode = newNode.add(disjPC.not).add(GNode::createFromPair("SelectionStatement", node.toPair)).as_GNode
				
				val tdn1 = new TopDownStrategy
				tdn1.register(new RemOneRule)
				tdn1.register(new RemZeroRule)
				tdn1.register(new SplitConditionalRule)
				tdn1.register(new ConstrainNestedConditionalsRule)
				newNode = tdn1.transform(newNode).as_GNode
			
				return newNode
			}
		}
		
		node
	}
	
}
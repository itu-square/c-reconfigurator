package dk.itu.models.rules.phase1normalize

import dk.itu.models.rules.AncestorGuaranteedRule
import dk.itu.models.strategies.TopDownStrategy
import xtc.lang.cpp.CTag
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.tree.GNode
import xtc.util.Pair
import dk.itu.models.Reconfigurator

class ExtractConditionalFromGlobalVariableInitializerRule extends AncestorGuaranteedRule {
	
	override dispatch PresenceCondition transform(PresenceCondition cond) {
		cond
	}

	override dispatch Language<CTag> transform(Language<CTag> lang) {
		lang
	}
	
	private def Iterable<PresenceCondition> firstNestedPCs(GNode node) {
		if (node.name.equals("Conditional")) {
			return node.filter(PresenceCondition)
		} else {
			for (GNode child : node.filter(GNode)) {
				val res = child.firstNestedPCs
				if (res != null) return res
			}
			return null
		}
	}

	override dispatch Pair<Object> transform(Pair<Object> pair) {
		pair
	}
	
	override dispatch Object transform(GNode node) {		
		if (
			node.name.equals("Declaration")
			&& !ancestors.exists[anc | anc.name.equals("FunctionDefinition")]
			
			&& (node.get(0) instanceof GNode)
			&& (node.get(0) as GNode).name.equals("DeclaringList")
			
			&& (node.get(0) as GNode).filter(GNode).exists[name.equals("InitializerOpt")]
			&& (node.get(0) as GNode).firstNestedPCs != null
		) {
			val declaringList = node.get(0) as GNode
			val pcs = declaringList.firstNestedPCs
			
			if (pcs != null) {
				var newNode = GNode::create("Conditional")
				
				var disjPC = Reconfigurator::presenceConditionManager.newPresenceCondition(false)
				for (PresenceCondition pc : pcs) {
					newNode = newNode.add(pc).add(node) as GNode
					disjPC = disjPC.or(pc)
				}
				newNode = newNode.add(disjPC.not).add(node) as GNode
				
				val tdn1 = new TopDownStrategy
				tdn1.register(new RemOneRule)
				tdn1.register(new RemZeroRule)
				tdn1.register(new SplitConditionalRule)
				tdn1.register(new ConstrainNestedConditionalsRule)
				newNode = tdn1.transform(newNode) as GNode
				
				return newNode
			}
		}
		
		node
	}
	
}
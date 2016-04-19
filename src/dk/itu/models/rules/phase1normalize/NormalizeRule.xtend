package dk.itu.models.rules.phase1normalize

import dk.itu.models.rules.Rule
import dk.itu.models.strategies.TopDownStrategy
import xtc.lang.cpp.CTag
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.tree.GNode
import xtc.tree.Node
import xtc.util.Pair

class NormalizeRule extends Rule  {
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
		
		var Node normalized = node
		
		val tdn1 = new TopDownStrategy
		tdn1.register(new RemOneRule)
		tdn1.register(new RemZeroRule)
		tdn1.register(new SplitConditionalRule)
		tdn1.register(new ConstrainNestedConditionalsRule)
		tdn1.register(new ConditionPushDownRule)
		tdn1.register(new MergeSequentialMutexConditionalRule)
		tdn1.register(new ReorderSequentialMutexConditionalRule)
		tdn1.register(new ExtractInitializerRule)
		normalized = tdn1.transform(normalized) as Node
		
		val tdn2 = new TopDownStrategy
		tdn2.register(new MergeConditionalsRule)
		tdn2.register(new OptimizeAssignmentExpressionRule)
		tdn2.register(new EnforceBracesInSelectionStatementRule)
		normalized = tdn2.transform(normalized) as Node
		
		if(normalized != node)
			return normalized
		
		node
	}
}
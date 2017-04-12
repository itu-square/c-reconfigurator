package dk.itu.models.rules.phase1normalize

import dk.itu.models.rules.Rule
import org.eclipse.xtext.xbase.lib.Functions.Function1
import xtc.lang.cpp.CTag
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.tree.GNode
import xtc.util.Pair

class ParametricRemNodesRule extends Rule {
	
	Function1<Object, Boolean> test
	
	new (Function1<Object, Boolean> test) {
		super()
		this.test = test
	}
	
	override dispatch PresenceCondition transform(PresenceCondition cond) {
		cond
	}

	override dispatch Language<CTag> transform(Language<CTag> lang) {
		lang
	}

	override dispatch Pair<Object> transform(Pair<Object> pair) {
		if (
			!pair.empty
			&& test.apply(pair.head)
		) {
			return pair.tail
		} else {
			return pair
		}
	}
	
	override dispatch Object transform(GNode node) {
		node
	}
	
}
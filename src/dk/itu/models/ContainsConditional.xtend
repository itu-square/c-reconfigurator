package dk.itu.models

import xtc.lang.cpp.CTag
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.tree.GNode

class ContainsConditional {

	static def boolean containsConditional(Object o) {
		t(o)
	}

	static def private dispatch boolean t(PresenceCondition condition) {
		false
	}

	static def private dispatch boolean t(Language<CTag> language) {
		false
	}

	static def private dispatch boolean t(GNode node) {
		if (node.name.equals("Conditional"))
			true
		else
			node.exists[t]
	}

}

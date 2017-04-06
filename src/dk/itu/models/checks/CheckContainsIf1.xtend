package dk.itu.models.checks

import xtc.lang.cpp.CTag
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.tree.GNode

import static extension dk.itu.models.Extensions.*

class CheckContainsIf1 {

	static def boolean check(Object o) {
		t(o)
	}

	static def private dispatch boolean t(PresenceCondition condition) {
		false
	}

	static def private dispatch boolean t(Language<CTag> language) {
		false
	}

	static def private dispatch boolean t(GNode node) {
		if (
			node.name.equals("Conditional")
			&& node.get(0).as_PresenceCondition.toString.equals("1")
		) {
			println("check: ContainsIf1")
			true
		} else
			node.exists[t]
	}

}

package dk.itu.models.rules

import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.lang.cpp.CTag
import xtc.tree.GNode
import xtc.util.Pair

class PrintScopeRule extends ScopingRule {
	
	override dispatch PresenceCondition transform(PresenceCondition cond) {
		super.transform(cond)
		println(cond)
		localVariables.forEach[println(it.value)]
		println
		cond
	}

	override dispatch Language<CTag> transform(Language<CTag> lang) {
		super.transform(lang)
		println(lang)
		localVariables.forEach[println(it.value)]
		println
		lang
	}

	override dispatch Pair<Object> transform(Pair<Object> pair) {
		super.transform(pair)
		println(pair)
		localVariables.forEach[println(it.value)]
		println
		pair
	}
	
	override dispatch Object transform(GNode node) {
		super.transform(node)
		println(node)
		localVariables.forEach[println(it.value)]
		println
		node
	}
	
}
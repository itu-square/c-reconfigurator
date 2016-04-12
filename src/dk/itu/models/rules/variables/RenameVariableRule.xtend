package dk.itu.models.rules.variables

import xtc.lang.cpp.CTag
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.lang.cpp.Syntax.Text
import xtc.tree.GNode
import xtc.util.Pair

class RenameVariableRule extends dk.itu.models.rules.AncestorGuaranteedRule {
	
	val String newName
	
	new (String name) {
		newName = name
	}
	
	override dispatch PresenceCondition transform(PresenceCondition cond) {
		cond
	}

	override dispatch Language<CTag> transform(Language<CTag> lang) {
		if (ancestors.get(ancestors.size-1).name.equals("SimpleDeclarator")
			&& ancestors.exists[name.equals("Declaration")]
			&& !lang.toString.equals(newName)) {
				val newName = new Text<CTag>(CTag.IDENTIFIER, newName)
				newName.setProperty("reconfiguratorVariable", true)
				newName
		} else {
			lang
		}
	}

	override dispatch Pair<Object> transform(Pair<Object> pair) {
		pair
	}
	
	override dispatch Object transform(GNode node) {
		node
	}

}
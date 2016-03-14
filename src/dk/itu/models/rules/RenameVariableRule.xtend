package dk.itu.models.rules

import xtc.lang.cpp.CTag
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.tree.GNode
import xtc.util.Pair
import xtc.lang.cpp.Syntax.Text
import xtc.lang.cpp.Syntax.Text

class RenameVariableRule extends Rule {
	
	val String newName
	
	new (String name) {
		newName = name
	}
	
	override dispatch PresenceCondition transform(PresenceCondition cond) {
		cond
	}

	override dispatch Language<CTag> transform(Language<CTag> lang) {
		if (ancestors.get(ancestors.size-1).name.equals("SimpleDeclarator")
			&& ancestors.get(ancestors.size-2).name.equals("DeclaringList")
			&& !lang.toString.equals(newName))
			return new Text<CTag>(CTag.IDENTIFIER, newName)
		else
			lang
	}

	override dispatch Pair<?> transform(Pair<?> pair) {
		pair
	}
	
	override dispatch Object transform(GNode node) {
		node
	}

}
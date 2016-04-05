package dk.itu.models.rules

import xtc.lang.cpp.CTag
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.lang.cpp.Syntax.Text
import xtc.tree.GNode
import xtc.util.Pair

class ReplaceIdentifiersRule extends Rule {
	
	protected val String newIdentifier
	
	new (String newIdentifier) {
		super()
		this.newIdentifier = newIdentifier
	}
	
	override dispatch PresenceCondition transform(PresenceCondition cond) {
		cond
	}

	override dispatch Language<CTag> transform(Language<CTag> lang) {
		if (
			lang.tag.equals(CTag::IDENTIFIER)
			&& !lang.toString.equals(newIdentifier)
		) {
			return new Text(CTag.IDENTIFIER, newIdentifier)
		}
		lang
	}

	override dispatch Pair<Object> transform(Pair<Object> pair) {
		pair
	}
	
	override dispatch Object transform(GNode node) {
		node
	}
}
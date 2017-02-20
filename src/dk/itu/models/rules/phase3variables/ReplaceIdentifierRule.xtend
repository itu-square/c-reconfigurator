package dk.itu.models.rules.phase3variables

import xtc.lang.cpp.CTag
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.lang.cpp.Syntax.Text
import xtc.tree.GNode
import xtc.util.Pair
import dk.itu.models.rules.AncestorGuaranteedRule

class ReplaceIdentifierRule extends AncestorGuaranteedRule {
	
	protected val String oldIdentifier
	protected val String newIdentifier
	
	new (String oldIdentifier, String newIdentifier) {
		super()
		this.oldIdentifier = oldIdentifier
		this.newIdentifier = newIdentifier
	}
	
	override dispatch PresenceCondition transform(PresenceCondition cond) {
		cond
	}

	override dispatch Language<CTag> transform(Language<CTag> lang) {
		if (
			lang instanceof Text<?>
			&& #[CTag::IDENTIFIER, CTag::TYPEDEFname].contains((lang as Text<CTag>).tag)
			&& lang.toString.equals(oldIdentifier)
		) {
			return new Text(lang.tag, newIdentifier)
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
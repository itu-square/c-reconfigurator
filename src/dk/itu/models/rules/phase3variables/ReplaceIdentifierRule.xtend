package dk.itu.models.rules.phase3variables

import dk.itu.models.rules.AncestorGuaranteedRule
import org.eclipse.xtext.xbase.lib.Functions.Function1
import xtc.lang.cpp.CTag
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.lang.cpp.Syntax.Text
import xtc.tree.GNode
import xtc.util.Pair

class ReplaceIdentifierRule extends AncestorGuaranteedRule {
	
	protected val String oldIdentifier
	protected val String newIdentifier
	protected var Function1<AncestorGuaranteedRule, Boolean> test
	
	new (String oldIdentifier, String newIdentifier) {
		super()
		this.oldIdentifier = oldIdentifier
		this.newIdentifier = newIdentifier
	}
	
	new(String oldIdentifier, String newIdentifier, Function1<AncestorGuaranteedRule, Boolean> test) {
		super()
		this.oldIdentifier = oldIdentifier
		this.newIdentifier = newIdentifier
		this.test = test
	}
	
	override dispatch PresenceCondition transform(PresenceCondition cond) {
		cond
	}

	override dispatch Language<CTag> transform(Language<CTag> lang) {
		if (
			lang instanceof Text<?>
			&& #[CTag::IDENTIFIER, CTag::TYPEDEFname].contains((lang as Text<CTag>).tag)
			&& lang.toString.equals(oldIdentifier)
			&& (test === null || test.apply(this))
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
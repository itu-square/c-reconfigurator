package dk.itu.models.rules

import java.util.ArrayList
import xtc.tree.GNode
import xtc.tree.Node
import dk.itu.models.Reconfigurator
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.lang.cpp.CTag
import xtc.util.Pair

abstract class AncestorGuaranteedRule extends Rule {
	
	protected var ArrayList<GNode> ancestors
	
	def init(ArrayList<GNode> ancestors) {
		this.ancestors = ancestors
		this
	}

	def protected PresenceCondition guard(Node node) {
		val lastGuard = ancestors.findLast[it.name == "Conditional"]
		if (lastGuard == null) {
			return Reconfigurator.presenceConditionManager.newPresenceCondition(true)
		} else {
			val child = if (ancestors.indexOf(lastGuard) < ancestors.size-1)
				ancestors.get(ancestors.indexOf(lastGuard) + 1)
				else node
			val condition = lastGuard.findLast [
				it instanceof PresenceCondition && lastGuard.indexOf(it) < lastGuard.indexOf(child)
			]
			return condition as PresenceCondition
		}
	}

	override dispatch PresenceCondition transform(PresenceCondition cond) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	override dispatch Language<CTag> transform(Language<CTag> lang) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	override dispatch Pair<Object> transform(Pair<Object> pair) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	override dispatch Object transform(GNode node) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}	
	
}
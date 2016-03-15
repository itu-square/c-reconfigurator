package dk.itu.models.rules

import java.util.ArrayList
import xtc.tree.GNode
import xtc.tree.Node
import dk.itu.models.Reconfigurator
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition

abstract class AncestorGuaranteedRule extends Rule {
	
	protected var ArrayList<GNode> ancestors
	
	def init(ArrayList<GNode> ancestors) {
		this.ancestors = ancestors
		this
	}

	def protected guard(Node node) {
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
			return condition
		}
	}
	
}
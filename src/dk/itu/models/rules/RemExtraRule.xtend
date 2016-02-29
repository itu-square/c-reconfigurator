package dk.itu.models.rules

import dk.itu.models.Reconfigurator
import xtc.lang.cpp.CTag
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.tree.GNode
import xtc.tree.Node
import xtc.util.Pair

class RemExtraRule extends Rule {

	override dispatch PresenceCondition transform(PresenceCondition cond) {
		cond
	}

	override dispatch Language<CTag> transform(Language<CTag> lang) {
		lang
	}

	override dispatch Pair<?> transform(Pair<?> pair) {
		pair
	}

	def private guard(Node node) {
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

	override dispatch Object transform(GNode node) {
		if (node.name == "Conditional" && node.size == 2) {
			val c = (node.get(0) as PresenceCondition)
			val g = guard(node) as PresenceCondition
			
			if (g.getBDD.imp(c.getBDD).isOne) {
				node.get(1)
			} else {
				node
			}
		} else {
			node
		}
	}

}
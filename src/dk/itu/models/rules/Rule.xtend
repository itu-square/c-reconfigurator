package dk.itu.models.rules

import java.util.ArrayList
import xtc.lang.cpp.CTag
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.tree.GNode
import xtc.util.Pair
import xtc.tree.Node
import dk.itu.models.PrintCode

abstract class Rule {

	protected var ArrayList<GNode> ancestors

	def init(ArrayList<GNode> ancestors) {
		this.ancestors = ancestors
		this
	}

	def dispatch PresenceCondition transform(PresenceCondition cond) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	def dispatch Language<CTag> transform(Language<CTag> lang) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	def dispatch Pair<?> transform(Pair<?> pair) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	def dispatch Object transform(GNode node) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	def Pair<?> toPair(GNode node) {
		var Pair<?> p = Pair.empty()
		for (var i = node.size - 1; i >= 0; i--) {
			p = new Pair(node.get(i), p)
		}
		p
	}
	
	def printCode(Node node) {
		PrintCode::printCode(node)
	}
}
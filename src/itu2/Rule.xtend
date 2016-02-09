package itu2

import java.util.ArrayList
import xtc.lang.cpp.CTag
import xtc.lang.cpp.PresenceConditionManager
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.tree.GNode

abstract class Rule {
	
	protected var PresenceConditionManager manager
	protected var ArrayList<GNode> ancestors
	
	def init (PresenceConditionManager manager, ArrayList<GNode> ancestors) {
		this.manager = manager
		this.ancestors = ancestors
		this
	}
	
	def dispatch PresenceCondition transform(PresenceCondition cond) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	def dispatch Language<CTag> transform(Language<CTag> lang) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	def dispatch GNode transform(GNode node) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
}
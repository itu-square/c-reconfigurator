package itu2

import java.util.ArrayList
import xtc.lang.cpp.CTag
import xtc.lang.cpp.PresenceConditionManager
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.tree.GNode
import xtc.util.Pair

abstract class Strategy {
	
	protected val PresenceConditionManager manager
	protected val ArrayList<GNode> ancestors
	protected val ArrayList<Rule> rules
	
	new(PresenceConditionManager manager) {
		this.manager = manager
    	this.ancestors = new ArrayList<GNode>
    	this.rules = new ArrayList<Rule>
	}
	
	def register(Rule rule) {
		rules.add(rule.init(manager, ancestors))
	}
	
	
	
	def dispatch PresenceCondition visit(PresenceCondition cond) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	def dispatch Language<CTag> visit(Language<CTag> lang) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	def dispatch Pair<?> visit(Pair<?> pair) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	def dispatch Object visit(GNode node) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	
	
	def Pair<?> toPair(GNode node){
		var Pair<?> p = Pair.empty()
		for(var i = node.size-1; i >= 0; i--) {
			p = new Pair(node.get(i), p)
		}
		p
	}
	
}
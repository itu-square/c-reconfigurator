package dk.itu.models

import xtc.lang.cpp.PresenceConditionManager
import java.util.List
import xtc.tree.Node
import xtc.lang.cpp.Syntax.Language
import xtc.lang.cpp.CTag
import xtc.tree.GNode
import java.util.ArrayList
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition

class TxIdentity {
	
	// the PresenceConditionManager which was used when building the AST
	// without this it is not possible to access the variable names in the PresenceConditions
	protected val PresenceConditionManager manager
	
	// a list of all ancestors of the current node
	// various uses (e.g. indentation)
	protected val ArrayList<Node> ancestors
	
	new(PresenceConditionManager manager) {
		this.manager = manager
    	this.ancestors = new ArrayList<Node>
	}
	
	def transform(Object o) {
		ancestors.clear
		t(o)
	}
	
	def private dispatch PresenceCondition t(PresenceCondition condition) {
		manager.newPresenceCondition(condition.getBDD)
	}

	def private dispatch Language<CTag> t(Language<CTag> language) {
		language.copy
	}

	def private dispatch GNode t(GNode node) {
		ancestors.add(node)
		
		val newNode = GNode::create(node.name)
		node.forEach[newNode.add(t(it))]
		
		ancestors.remove(node)
		
		newNode
	}
	
}
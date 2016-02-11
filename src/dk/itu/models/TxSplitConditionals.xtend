package dk.itu.models

import xtc.lang.cpp.PresenceConditionManager
import xtc.util.Pair
import xtc.tree.Node
import xtc.lang.cpp.Syntax.Language
import xtc.lang.cpp.CTag
import xtc.tree.GNode
import java.util.ArrayList
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition

class TxSplitConditionals {
	
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
	
	def private dispatch Pair<?> split(GNode node) {
		var p = Pair.empty
		var n = GNode.create("Conditional")
		for(var i = node.size-1; i >=0; i--) {
			n.add(node.get(i))
			if(node.get(i) instanceof PresenceCondition){
				p = new Pair(n, p)
				n = GNode.create("Conditional")
			}
		}
		p
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
		
		node.forEach[
			if (it instanceof GNode && (it as GNode).name == "Conditional")
				newNode.addAll(split(it as GNode))
			else
				newNode.add(t(it))
		]
			
		ancestors.remove(node)
			
		newNode
	}
	
}
package itu

import xtc.lang.cpp.PresenceConditionManager
import java.util.List
import xtc.tree.Node
import xtc.lang.cpp.Syntax.Language
import xtc.lang.cpp.CTag
import xtc.tree.GNode
import java.util.ArrayList
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition

class TxRemOnes  {
	
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
	
	def dispatch PresenceCondition t(PresenceCondition condition) {
		manager.newPresenceCondition(condition.BDD)
	}

	def dispatch Language<CTag> t(Language<CTag> language) {
		language.copy
	}

	def dispatch Node t(Node node) {
			if(node.name == "Conditional"
			&& node.size == 2
			&& node.get(0).toString.equals("1")){
				
				ancestors.add(node)
				
				val newNode = t(node.get(1)) as Node
				
				ancestors.remove(node)
				
				newNode
			}
			else {
				ancestors.add(node)
		
				val newNode = GNode::create(node.name)
				node.forEach[newNode.add(t(it))]
				
				ancestors.remove(node)
				
				newNode
			}
	}
	
}
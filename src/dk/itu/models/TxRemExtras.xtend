package dk.itu.models

import xtc.lang.cpp.PresenceConditionManager
import java.util.List
import xtc.tree.Node
import xtc.lang.cpp.Syntax.Language
import xtc.lang.cpp.CTag
import xtc.tree.GNode
import java.util.ArrayList
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition

class TxRemExtras  {
	
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
	
	
	def private guard (Node node) {
		val lastGuard = ancestors.findLast[it.name == "Conditional"]
		
		if(lastGuard == null) {
//			println(manager.newPresenceCondition(true))
			return manager.newPresenceCondition(true)
		}
		else {
//			println(lastGuard)
			val child = ancestors.get(ancestors.indexOf(lastGuard) +1)
//			println(lastGuard.indexOf(child) + " " + child)
			
			val condition = lastGuard.findLast[it instanceof PresenceCondition && lastGuard.indexOf(it) < lastGuard.indexOf(child)]
//			println(condition)
			return condition
		}
	}
	

	def private dispatch Node t(Node node) {
			if(node.name == "Conditional"
				&& node.size == 2
			){
				val c = (node.get(0) as PresenceCondition)
				val g = guard(node) as PresenceCondition
//				println(c + "\n guarded by \n" + g)
//				println(c.is(g) )
//				println('''(«g.BDD» -> «c.BDD» : «g.BDD.imp(c.BDD).isOne»)''')
//				
//				println
//				println
				
				if(g.getBDD.imp(c.getBDD).isOne){
					ancestors.add(node)
					val newNode = t(node.get(1)) as Node
					ancestors.remove(node)
					newNode
				} else {
					ancestors.add(node)
					val newNode = GNode::create(node.name)
					node.forEach[newNode.add(t(it))]
					ancestors.remove(node)			
					newNode
				}
			} else {
				ancestors.add(node)
				val newNode = GNode::create(node.name)
				node.forEach[newNode.add(t(it))]
				ancestors.remove(node)
				newNode
			}
	}
	
}
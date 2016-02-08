package itu

import xtc.lang.cpp.PresenceConditionManager
import xtc.util.Pair
import xtc.tree.Node
import xtc.lang.cpp.Syntax.Language
import xtc.lang.cpp.CTag
import xtc.tree.GNode
import java.util.ArrayList
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import java.util.Collection

class TxMergeSeqI {
	
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
	
	def private dispatch Pair<?> t(Pair<?> pair) {
		if (pair.isEmpty)
			pair
		else {
			if(		pair.head instanceof GNode
					&& (pair.head as GNode).name == "Conditional"
					&& (pair.head as GNode).size == 2){
				var c1 = pair.head as GNode
				var tail = t(pair.tail) as Pair<?>
				var c2 = tail.head as GNode
				var rest = tail.tail
				if(c1.name == "Conditional" && c1.size == 2 && c2.name == "Conditional"
					&& (c1.get(0) as PresenceCondition).is((c2.get(0) as PresenceCondition))) {
//					println(pair.head)
//					println(pair.tail.head)
//					println((c1.get(0) as PresenceCondition).is((c2.get(0) as PresenceCondition)) )
//					println()
					var toMove = c1.get(1)
					var destination = c2.add(1, toMove)
//					t(new Pair(destination, rest)) as Pair<?>
					new Pair(destination, rest)
				}
				else
					new Pair(t(pair.head), t(pair.tail) as Pair<?>)
			}
			else
				new Pair(t(pair.head), t(pair.tail) as Pair<?>)	
		}
	}
	
	def private dispatch PresenceCondition t(PresenceCondition condition) {
		manager.newPresenceCondition(condition.BDD)
	}

	def private dispatch Language<CTag> t(Language<CTag> language) {
		language.copy
	}

	def private dispatch GNode t(GNode node) {
		//println(node)
		ancestors.add(node)
		
		val newNode = GNode::create(node.name)
		newNode.addAll(t(node.toPair) as Pair<?>)
		
		ancestors.remove(node)
		
		newNode
	}
	
	def Pair<?> toPair(GNode node){
		var Pair<?> p = Pair.empty()
		for(var i = node.size-1; i >= 0; i--) {
			p = new Pair(node.get(i), p)
		}
		p
	}
	
}
package dk.itu.models.rules

import dk.itu.models.Reconfigurator
import java.util.ArrayList
import xtc.lang.cpp.CTag
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.tree.GNode
import xtc.tree.Node
import xtc.util.Pair

import static extension dk.itu.models.Extensions.*

abstract class AncestorGuaranteedRule extends Rule {
	
	protected var ArrayList<GNode> ancestors
	
	def init(ArrayList<GNode> ancestors) {
		this.ancestors = ancestors
		this
	}

	def protected PresenceCondition guard(Node node) {
		val lastGuard = ancestors.findLast[it.name == "Conditional"]
		if (lastGuard === null) {
			return Reconfigurator.presenceConditionManager.newPresenceCondition(true)
		} else {
			val child = if (ancestors.indexOf(lastGuard) < ancestors.size-1)
				ancestors.get(ancestors.indexOf(lastGuard) + 1)
				else node
			val condition = lastGuard.findLast [
				it.is_PresenceCondition && lastGuard.indexOf(it) < lastGuard.indexOf(child)
			]
			
//			println(ancestors.indexOf(lastGuard) < ancestors.size-1)
//			println("anc1 :> " + ancestors.get(ancestors.indexOf(lastGuard) + 1).printCode)
//			println("chld :> " + child.printCode)
//			println("gurd :> " + lastGuard.printCode)
//			println
			
			return condition.as_PresenceCondition
		}
	}
	
	// Computes the conjunction of all ancestor PresenceConditions of a Node.
	def protected PresenceCondition presenceCondition(Node node) {
		// Create a starting point.
		var PresenceCondition result = Reconfigurator::presenceConditionManager.newPresenceCondition(true)
		
		for(var i = 0; i <= ancestors.size-2; i++) {
			
			val ancestor = ancestors.get(i) 
			if(ancestor.name.equals("Conditional")) {
				
				val child = ancestors.get(i+1)
				result = result.and(ancestor.findLast[
					it.is_PresenceCondition && ancestor.indexOf(it) < ancestor.indexOf(child)
				].as_PresenceCondition ?: Reconfigurator::presenceConditionManager.newPresenceCondition(true))	
			}
		}
		
		if(ancestors.size > 0 && ancestors.last.name.equals("Conditional")) {		
			result = result.and(ancestors.last.findLast[
				it.is_PresenceCondition && ancestors.last.indexOf(it) < ancestors.last.indexOf(node)
			].as_PresenceCondition ?: Reconfigurator::presenceConditionManager.newPresenceCondition(true))	
		}
		
		result
	}

	override dispatch PresenceCondition transform(PresenceCondition cond) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	override dispatch Language<CTag> transform(Language<CTag> lang) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	override dispatch Pair<Object> transform(Pair<Object> pair) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	override dispatch Object transform(GNode node) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}	
	
}
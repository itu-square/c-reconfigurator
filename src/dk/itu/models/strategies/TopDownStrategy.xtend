package dk.itu.models.strategies

import dk.itu.models.rules.Rule
import xtc.lang.cpp.CTag
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.tree.GNode
import xtc.util.Pair
import static extension dk.itu.models.Extensions.*
import dk.itu.models.Settings
import dk.itu.models.Reconfigurator

class TopDownStrategy extends AncestorGuaranteedStrategy {

	override dispatch PresenceCondition transform(PresenceCondition cond) {
		var PresenceCondition newCond = cond
		for (Rule rule : rules) {
			newCond = rule.transform(newCond).as_PresenceCondition
		}
		newCond
	}
	
	override dispatch Language<CTag> transform(Language<CTag> lang) {
		var Language<CTag> newLang = lang
		for (Rule rule : rules) {
			newLang = rule.transform(newLang) as Language<CTag>
		}
		newLang
	}

	override dispatch Pair<Object> transform(Pair<Object> pair) {
		if (!pair.empty) {
			
			var Pair<Object> prev
			var Pair<Object> newPair = pair
			
			prev = newPair
			for (Rule rule : rules) {
				newPair = rule.transform(newPair) as Pair<Object>
				if (newPair != prev) return newPair
			}
			
			if(!newPair.empty) {
				val oldHead = newPair.head
				val Object newHead = transform(oldHead)
				
				if (oldHead.is_GNode && newHead.is_GNode && oldHead.as_GNode.location !== null)
					newHead.as_GNode.location = oldHead.as_GNode.location
				
				val oldTail = newPair.tail
				val Pair<Object> newTail = transform(oldTail) as Pair<Object>
				if(!newHead.equals(oldHead) || !newTail.equals(oldTail)) 
					newPair = new Pair(newHead, newTail)
			}
			
			return newPair
		}
		
		pair
	}

	override dispatch Object transform(GNode node) {
		
		val locs = node.nestedNodesLocations
		
		if (
			!Settings::reconfigureIncludes
			&& ancestors.size >= 1
			&& ancestors.last.name.equals("ExternalDeclarationList")
			&& !locs.contains(Reconfigurator::file)
		) {
			return node
		}
		
		var GNode prev
		var Object newNode = node
		
		do {
			prev = newNode.as_GNode
			for (Rule rule : rules) {
				newNode = rule.transform(newNode)
			}
			
			if (newNode instanceof GNode) {
				val ancestor = newNode
				ancestors.add(ancestor)
				
				val newNodeConst = newNode
				newNode = GNode::createFromPair(
					newNode.name,
					transform(newNode.toPair) as Pair<Object>,
					if (newNode.properties === null)
						null
					else
						newNode.properties.toInvertedMap[p | newNodeConst.getProperty(p.toString)]
				)
				if (newNodeConst.location !== null)
					newNode.as_GNode.location = newNodeConst.location
				ancestors.remove(ancestor)
				if(newNode != ancestor && ancestors.size != 0)
					return newNode
			}
		
		} while (newNode != prev)
		
		newNode
	}

}
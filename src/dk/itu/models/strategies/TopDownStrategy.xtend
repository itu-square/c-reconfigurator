package dk.itu.models.strategies

import dk.itu.models.rules.Rule
import xtc.lang.cpp.CTag
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.tree.GNode
import xtc.util.Pair
import static extension dk.itu.models.Extensions.*

class TopDownStrategy extends AncestorGuaranteedStrategy {

	override dispatch PresenceCondition transform(PresenceCondition cond) {
		var PresenceCondition newCond = cond
		for (Rule rule : rules) {
			newCond = rule.transform(newCond) as PresenceCondition
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
			
			do {
				prev = newPair
				for (Rule rule : rules) {
					newPair = rule.transform(newPair) as Pair<Object>
					if (newPair != prev) return newPair
				}
			} while (newPair != prev)
			
			if(!newPair.empty) {
				var Object newHead = transform(newPair.head)	
				var Pair<Object> newTail = transform(newPair.tail) as Pair<Object>
				newPair = new Pair(newHead, newTail)
			}
			
			return newPair
		}
		
		pair
	}

	override dispatch Object transform(GNode node) {
		
		var GNode prev
		var Object newNode = node
		
		do {
			prev = newNode as GNode
			for (Rule rule : rules) {
				newNode = rule.transform(newNode)
			}
			
			if (newNode instanceof GNode) {
				val ancestor = newNode
				ancestors.add(ancestor)
				newNode = GNode::createFromPair(
					newNode.name,
					transform(newNode.toPair) as Pair<Object>
				)
				ancestors.remove(ancestor)
			}
		
		} while (newNode != prev)
		
		newNode
	}

}
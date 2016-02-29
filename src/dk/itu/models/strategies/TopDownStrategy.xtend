package dk.itu.models.strategies

import dk.itu.models.rules.Rule
import xtc.lang.cpp.CTag
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.tree.GNode
import xtc.util.Pair

class TopDownStrategy extends Strategy {

	override dispatch PresenceCondition transform(PresenceCondition cond) {
		cond
	}

	override dispatch Language<CTag> transform(Language<CTag> lang) {
		
		var Language<CTag> newLang = lang
		
		for (Rule rule : rules) {
			newLang = rule.transform(newLang) as Language<CTag>
		}
		
		newLang
	}

	override dispatch Pair<?> transform(Pair<?> pair) {
		if (pair.isEmpty) return pair
		
		var Pair<?> newPair = pair
		
		for (Rule rule : rules) {
			newPair = rule.transform(newPair) as Pair<?>
		}
		
		var Object newHead = transform(newPair.head)	
		var Pair<?> newTail = transform(newPair.tail) as Pair<?>
		
		newPair = if (!newTail.equals(pair.tail) || !newHead.equals(pair.head))
			new Pair(newHead, newTail)
			else pair
		
		newPair
	}

	override dispatch Object transform(GNode node) {
		var Object newNode = node
		
		var Object prev = newNode
		for (Rule rule : rules) {
			newNode = rule.transform(newNode)
		}
		
		ancestors.add(node)
		var Pair<?> oldPair = node.toPair
		var Pair<?> newPair = transform(oldPair) as Pair<?>
		if(!oldPair.equals(newPair)) {
			newNode =  GNode::create(node.name)
			(newNode as GNode).addAll(newPair)
		}
		ancestors.remove(node)
		
		if(!newNode.equals(prev))
			newNode = transform(newNode)
		
		newNode
	}

}
package dk.itu.models.strategies

import dk.itu.models.rules.Rule
import xtc.lang.cpp.CTag
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.tree.GNode
import xtc.util.Pair

import static extension dk.itu.models.Extensions.*

class BottomUpStrategy extends AncestorGuaranteedStrategy {
	
	new() {
		throw new UnsupportedOperationException("TODO: Fix this strategy. It cannot guarantee ancestors.")
	}

	override dispatch PresenceCondition transform(PresenceCondition cond) {
		cond
	}

	override dispatch Language<CTag> transform(Language<CTag> lang) {
		lang
	}

	override dispatch Pair<Object> transform(Pair<Object> pair) {
		if (pair.isEmpty) return pair
		
		var Pair<Object> newTail = transform(pair.tail) as Pair<Object>
		var Object newHead = transform(pair.head)	
		
		var Pair<Object> newPair = if (!newTail.equals(pair.tail) || !newHead.equals(pair.head))
			new Pair(newHead, newTail)
			else pair
		
		for (Rule rule : rules) {
			newPair = rule.transform(newPair) as Pair<Object>
		}

		newPair
	}

	override dispatch Object transform(GNode node) {
		println("ancestors " + ancestors.size)
		var Object newNode = node
		var Object prev = node
		do {
			prev = newNode
			if (newNode.is_GNode) {
			ancestors.add(newNode.as_GNode)
			var Pair<Object> oldPair = newNode.as_GNode.toPair
			var Pair<Object> newPair = transform(oldPair) as Pair<Object>
			ancestors.remove(newNode)
			if(!oldPair.equals(newPair)) {
				newNode =  GNode::create(node.name)
				newNode.as_GNode.addAll(newPair)
			}
			
	//		var Object prev = newNode
			if (newNode.equals(prev))
			for (Rule rule : rules) {
				println(rule.class)
				println(newNode)
				newNode = rule.transform(newNode)
				println(newNode)
				println
				
			}
			}
		}
		while(!newNode.equals(prev))
//			newNode = transform(newNode)
		
		
		newNode
	}

}
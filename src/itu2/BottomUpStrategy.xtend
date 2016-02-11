package itu2

import xtc.lang.cpp.CTag
import xtc.lang.cpp.PresenceConditionManager
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.tree.GNode
import xtc.util.Pair

class BottomUpStrategy extends Strategy {
	
	new(PresenceConditionManager manager) {
		super(manager)
	}
	
	override dispatch PresenceCondition visit(PresenceCondition cond) {
		println('''bus «cond»''')
//		manager.newPresenceCondition(cond.BDD)
		cond
	}
	
	override dispatch Language<CTag> visit(Language<CTag> lang) {
		println('''bus «lang»''')
//		lang.copy
		lang
	}
	
	override dispatch Pair<?> visit(Pair<?> pair) {
		if (pair.isEmpty)
			pair
		else {
			var Pair<?> newPair = new Pair(visit(pair.head), visit(pair.tail) as Pair<?>)
			
			println('''bus «pair»''')
			var Pair<?> prev = null
			while(newPair != prev){
				prev = newPair
				for (Rule rule : rules){
					newPair = rule.transform(newPair) as Pair<?>
				}
			}
			
			newPair
		}	
	}
	
	override dispatch Object visit(GNode node) {
		ancestors.add(node)
		
		var Object newNode = GNode::create(node.name)
//		for (child : node) {
//			(newNode as GNode).add(visit(child))
//		}
		(newNode as GNode).addAll(visit(node.toPair) as Pair<?>)

		ancestors.remove(node)
		
		println('''bus «node»''')
		var Object prev = null
		while(newNode != prev){
			prev = newNode
			for (Rule rule : rules){
				newNode = rule.transform(newNode)
			}
		}
	
		newNode
	}
	
	
}
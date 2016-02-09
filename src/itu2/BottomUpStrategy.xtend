package itu2

import xtc.lang.cpp.CTag
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.tree.GNode
import xtc.lang.cpp.PresenceConditionManager

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
	
	override dispatch GNode visit(GNode node) {
		ancestors.add(node)
		
		var newNode = GNode::create(node.name)
		for (child : node) {
			newNode.add(visit(child))
		}

		ancestors.remove(node)
		
		println('''bus «node»''')
		
		var GNode prev = null
		
		while(newNode != prev){
			prev = newNode
			for (Rule rule : rules){
				newNode = rule.transform(prev) as GNode
			}
		}
	
		newNode
	
	}
	
	
}
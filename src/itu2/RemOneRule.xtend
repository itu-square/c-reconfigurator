package itu2

import xtc.lang.cpp.CTag
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.tree.GNode

class RemOneRule extends Rule {
	
	override dispatch PresenceCondition transform(PresenceCondition cond) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	override dispatch Language<CTag> transform(Language<CTag> lang) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	override dispatch GNode transform(GNode node) {
		println(node)
		if(node.name == "Conditional"
			&& node.size == 2 // to look for other guarded statements or syntax
			&& node.get(0).toString.equals("1")){
				
				ancestors.add(node)
				
				val newNode = node.get(1) as GNode
				
				ancestors.remove(node)
				
				newNode
			}
			else {
				node
			}
	}

}
package dk.itu.models.rules

import xtc.lang.cpp.CTag
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.tree.GNode
import xtc.util.Pair

class SplitConditionalRule extends Rule {
	
	override dispatch PresenceCondition transform(PresenceCondition cond) {
		cond
	}

	override dispatch Language<CTag> transform(Language<CTag> lang) {
		lang
	}

	override dispatch Pair<?> transform(Pair<?> pair) {
		if(pair.head instanceof GNode
			&& (pair.head as GNode).name == "Conditional"
			&& (pair.head as GNode).filter(PresenceCondition).size >= 2) {
				val cond = pair.head as GNode
				
				var newPair = pair.tail
				for ( PresenceCondition pc : cond.filter(PresenceCondition).toList.reverseView) {
					var newNode = GNode::create("Conditional")
					newNode.setProperty("new", true)
					newNode.add(pc)					
					for(var index = cond.indexOf(pc)+1;
						index < cond.size && !(cond.get(index) instanceof PresenceCondition);
						index++) {
							newNode.add(cond.get(index))
						}
					newPair = new Pair(newNode, newPair)
				}
				
				newPair
			}
			else {
				pair
			}
	}

	override dispatch Object transform(GNode node) {
		node
	}
	
}
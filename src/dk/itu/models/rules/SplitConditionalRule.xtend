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
			&& (pair.head as GNode).name == "Conditional") {
				println('''[size: «pair.size»] [children: «(pair.head as GNode).size»]''')
				println(pair.head)
				
				val cond = pair.head as GNode
				cond.filter(PresenceCondition).forEach[println('''-- «it»''')]
				
				println
			}
		
		pair
	}

	override dispatch Object transform(GNode node) {
		node
	}
	
}
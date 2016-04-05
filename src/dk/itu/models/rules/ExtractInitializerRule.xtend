package dk.itu.models.rules

import xtc.lang.cpp.CTag
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.tree.GNode
import xtc.util.Pair
import static extension dk.itu.models.Extensions.*

class ExtractInitializerRule extends Rule {
	
	override dispatch PresenceCondition transform(PresenceCondition cond) {
		cond
	}

	override dispatch Language<CTag> transform(Language<CTag> lang) {
		lang
	}

	override dispatch Pair<Object> transform(Pair<Object> pair) {
		
		if (
			!pair.empty
			&& pair.head instanceof GNode
			&& (pair.head as GNode).name.equals("Declaration")
			
			&& (pair.head as GNode).get(0) instanceof GNode
			&& ((pair.head as GNode).get(0) as GNode).name.equals("DeclaringList")
			
			&& ((pair.head as GNode).get(0) as GNode).filter(GNode).findFirst[name.equals("InitializerOpt")] != null
		) {
			val initializer = ((pair.head as GNode).get(0) as GNode).filter(GNode).findFirst[name.equals("InitializerOpt")].get(1) as GNode 
			println('''initializer: «initializer.printCode»''')

//			println(
//				GNode::create(
//					"Declaration",
//					GNode::create(
//						"DeclaringList",
//						((pair.head as GNode).get(0) as GNode).get(0)
//						)))


// variable scope Thum & Schaefer

		}
		
		pair
	}
	
	override dispatch Object transform(GNode node) {		
		node
	}
	
}
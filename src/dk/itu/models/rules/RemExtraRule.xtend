package dk.itu.models.rules

import xtc.lang.cpp.CTag
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.tree.GNode
import xtc.util.Pair
import static extension dk.itu.models.Extensions.*

class RemExtraRule extends AncestorGuaranteedRule {

	override dispatch PresenceCondition transform(PresenceCondition cond) {
		cond
	}

	override dispatch Language<CTag> transform(Language<CTag> lang) {
		lang
	}

	override dispatch Pair<Object> transform(Pair<Object> pair) {
		if(
			!pair.empty &&
			
			(pair.head instanceof GNode) &&
			(pair.head as GNode).name == "Conditional" &&
			(pair.head as GNode).filter(PresenceCondition).size == 1 &&
			
			((pair.head as GNode).guard as PresenceCondition).BDD.imp(((pair.head as GNode).get(0) as PresenceCondition).BDD).isOne
		) {
//			println("RemExtra")
//			println(pair)
//			println("curr:> " + (pair.head as GNode).get(0) as PresenceCondition)
//			println("grd :> " + (pair.head as GNode).guard)
//			println((pair.head as GNode).toPair.tail.append(pair.tail))
//			println
			return (pair.head as GNode).toPair.tail.append(pair.tail)
		} else
			return pair
	}
	
	override dispatch Object transform(GNode node) {
		node
	}

}
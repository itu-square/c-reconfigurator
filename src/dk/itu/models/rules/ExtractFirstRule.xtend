package dk.itu.models.rules

import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.lang.cpp.CTag
import xtc.util.Pair
import xtc.tree.GNode
import static extension dk.itu.models.Extensions.*

class ExtractFirstRule extends Rule {
	
	new() {
		throw new UnsupportedOperationException("TODO: Fix this rule. Decide if it is even useful.")
	}
	
	override dispatch PresenceCondition transform(PresenceCondition cond) {
		cond
	}

	override dispatch Language<CTag> transform(Language<CTag> lang) {
		lang
	}

	override dispatch Pair<Object> transform(Pair<Object> pair) {
		if (pair.size >= 2 && pair.head instanceof GNode && pair.tail.head instanceof GNode) {
			var first = pair.head as GNode
			var second = pair.tail.head as GNode
			var tail = pair.tail.tail
				
			if	(first.name.equals("Conditional") && second.name.equals("Conditional") &&
				first.filter(PresenceCondition).size == 1 && second.filter(PresenceCondition).size == 1 &&
				(first.get(0) as PresenceCondition).is((second.get(0) as PresenceCondition).not)
			) {
					
					println
					println("ExtractFirstRule")
					println (first)
					val p1 = first.getChildrenGuardedBy(first.get(0) as PresenceCondition)
					p1.forEach[println("- " + it)]
					val p2 = second.getChildrenGuardedBy(second.get(0) as PresenceCondition)
					p2.forEach[println("+ " + it)]
					println(p1==p2)
				
//					println(first)
//					first.forEach[println("- " + it)]
//					println(second)
//					second.forEach[println("- " + it)]
					println("-->" + tail)
					println
					
//					var p = tail
//					p = new Pair(
//						GNode::createFromPair(
//							first.name,
//							(new MergeSequencesRule).transform(first.toPair.append(second.toPair)) as Pair<?>),
//						tail
//					)
//					p.forEach[println("= " + it)]
//					println
					return pair
			}
		}
		
		pair
	}
	
	override dispatch Object transform(GNode node) {
		node
	}
	
}
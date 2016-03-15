package dk.itu.models.rules

import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.lang.cpp.CTag
import xtc.util.Pair
import xtc.tree.GNode
import static extension dk.itu.models.Extensions.*

class MergeSequencesRule extends Rule {
	
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
				
			if(	(first.name.equals("CompoundStatement") && second.name.equals("CompoundStatement")) ||
				(first.name.equals("DeclarationOrStatementList") && second.name.equals("DeclarationOrStatementList"))
				) {
				
					println
					println("MergeSequencesRule")
					println("+ " + first)
					first.forEach[println(" + " + it)]
					println("- " + second)
					second.forEach[println(" - " + it)]
					println("--> " + tail)
					
					var p = tail
					p = new Pair(
						GNode::createFromPair(
							first.name,
							first.toPair.append(second.toPair)),
						tail
					)
					p.forEach[
						println("= " + it)
						if (it instanceof GNode)it.forEach[s | println("= " + s)]
					]
					println
					return p
			}
		}
		
		pair
	}
	
	override dispatch Object transform(GNode node) {
		node
	}
}
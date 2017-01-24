package dk.itu.models.rules.phase2prepare

import dk.itu.models.rules.AncestorGuaranteedRule
import xtc.lang.cpp.CTag
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.tree.GNode
import xtc.util.Pair

import static extension dk.itu.models.Extensions.*

class IsolateDeclarationRule extends AncestorGuaranteedRule {
	
	override dispatch PresenceCondition transform(PresenceCondition cond) {
		cond
	}

	override dispatch Language<CTag> transform(Language<CTag> lang) {
		lang
	}

	override dispatch Pair<Object> transform(Pair<Object> pair) {
		
		var GNode decl
		if (
			!pair.empty
			&& pair.size >= 1
			
			&& (pair.head instanceof GNode)
			&& (pair.head as GNode).name.equals("Conditional")
			&& (pair.head as GNode).size >= 3
		) {
			decl = (pair.head as GNode).findFirst[ c |
				c instanceof GNode
				&& (
					   (c as GNode).name.equals("Declaration")
					|| (c as GNode).name.equals("DeclarationExtension")
					|| (c as GNode).name.equals("FunctionDefinition")
					|| (
						    (c as GNode).name.equals("Conditional")
						&&  (c as GNode).size == 2
						&& ((c as GNode).get(1) instanceof GNode)
						&& #["Declaration", "DeclarationExtension"].contains(((c as GNode).get(1) as GNode).name)
					)
				)] as GNode
		}
		
		if (
			!pair.empty
			&& pair.size >= 1
			
			&& (pair.head instanceof GNode)
			&& (pair.head as GNode).name.equals("Conditional")
			&& (pair.head as GNode).size >= 3
			
			&& decl != null
		){
			val  declIndex = (pair.head as GNode).indexOf(decl)
			
			
			val Pair<Object> newPair =
				(if (declIndex > 1)
					new Pair<Object>(GNode::createFromPair(
						"Conditional",
						(pair.head as GNode).filterIndexed[e, index| index == 0 || index < declIndex].toPair))
					else Pair.EMPTY)
				.add(
					if (decl.name.equals("Conditional")) {
						GNode::create("Conditional",
							((pair.head as GNode).get(0) as PresenceCondition).and(decl.get(0) as PresenceCondition),
							decl.get(1)
						)}
					else
						GNode::createFromPair(
							"Conditional",
							(pair.head as GNode).filterIndexed[e, index| index == 0 || index == declIndex].toPair))
				.add(if (declIndex < (pair.head as GNode).size)
					GNode::createFromPair(
						"Conditional",
						(pair.head as GNode).filterIndexed[e, index|  index == 0 || index > declIndex].toPair)
					else Pair.EMPTY)
				.append(pair.tail)
				
			newPair
		} else {
			pair
		}
	}
	
	override dispatch Object transform(GNode node) {		
		node
	}

}
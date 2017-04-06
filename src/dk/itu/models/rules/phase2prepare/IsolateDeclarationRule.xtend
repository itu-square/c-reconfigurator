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
			
			&& pair.head.is_GNode("Conditional")
			&& pair.head.as_GNode.size >= 3
		) {
			decl = pair.head.as_GNode.findFirst[ c |
				c.is_GNode
				&& (
					   c.as_GNode.name.equals("Declaration")
					|| c.as_GNode.name.equals("DeclarationExtension")
					|| c.as_GNode.name.equals("FunctionDefinition")
					|| (
						    c.as_GNode.name.equals("Conditional")
						&&  c.as_GNode.size == 2
						&& (c.as_GNode.get(1).is_GNode)
						&& #["Declaration", "DeclarationExtension"].contains(c.as_GNode.get(1).as_GNode.name)
					)
				)].as_GNode
		}
		
		if (
			!pair.empty
			&& pair.size >= 1
			
			&& pair.head.is_GNode("Conditional")
			&& pair.head.as_GNode.size >= 3
			
			&& decl !== null
		){
			val  declIndex = pair.head.as_GNode.indexOf(decl)
			
			
			val Pair<Object> newPair =
				(if (declIndex > 1)
					new Pair<Object>(GNode::createFromPair(
						"Conditional",
						pair.head.as_GNode.filterIndexed[e, index| index == 0 || index < declIndex].toPair))
					else Pair.EMPTY)
				.add(
					if (decl.name.equals("Conditional")) {
						GNode::create("Conditional",
							pair.head.as_GNode.get(0).as_PresenceCondition.and(decl.get(0).as_PresenceCondition),
							decl.get(1)
						)}
					else
						GNode::createFromPair(
							"Conditional",
							pair.head.as_GNode.filterIndexed[e, index| index == 0 || index == declIndex].toPair))
				.add(if (declIndex < pair.head.as_GNode.size)
					GNode::createFromPair(
						"Conditional",
						pair.head.as_GNode.filterIndexed[e, index|  index == 0 || index > declIndex].toPair)
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
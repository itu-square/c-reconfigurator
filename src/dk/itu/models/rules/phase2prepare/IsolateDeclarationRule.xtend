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
		
		if (
			!pair.empty
			&& pair.size >= 1
			
			&& (pair.head instanceof GNode)
			&& (pair.head as GNode).name.equals("Conditional")
			&& (pair.head as GNode).size >= 3
			
			&& (pair.head as GNode).exists[ c |
				c instanceof GNode
				&& #["Declaration", "FunctionDefinition"].contains((c as GNode).name)]
		){
			val decl = (pair.head as GNode).findFirst[ c |
				c instanceof GNode
				&& #["Declaration", "FunctionDefinition"].contains((c as GNode).name)]
			val  declIndex = (pair.head as GNode).indexOf(decl)
			
			return
				(if (declIndex > 1)
					new Pair<Object>(GNode::createFromPair(
						"Conditional",
						(pair.head as GNode).filterIndexed[e, index| index == 0 || index < declIndex].toPair))
					else Pair.EMPTY)
				.add(
					GNode::createFromPair(
						"Conditional",
						(pair.head as GNode).filterIndexed[e, index| index == 0 || index == declIndex].toPair))
				.add(if (declIndex < (pair.head as GNode).size)
					GNode::createFromPair(
						"Conditional",
						(pair.head as GNode).filterIndexed[e, index|  index == 0 || index > declIndex].toPair)
					else Pair.EMPTY)
				.append(pair.tail)
		}
		
		pair
	}
	
	override dispatch Object transform(GNode node) {		
		node
	}

}
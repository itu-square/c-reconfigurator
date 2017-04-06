package dk.itu.models.rules.phase5cleanup

import dk.itu.models.rules.Rule
import xtc.lang.cpp.CTag
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.tree.GNode
import xtc.util.Pair

import static extension dk.itu.models.Extensions.*

class Specific_ExtractRParenFromConditionalRule extends Rule {
	
	override dispatch PresenceCondition transform(PresenceCondition cond) {
		cond
	}

	override dispatch Language<CTag> transform(Language<CTag> lang) {
		lang
	}

	override dispatch Pair<Object> transform(Pair<Object> pair) {
		pair
	}
	
	override dispatch Object transform(GNode node) {
		
		if (
			node.name.equals("SelectionStatement")
			
			&& node.get(0) instanceof Language<?>
			&& (node.get(0) as Language<CTag>).tag.equals(CTag::^IF)
			
			&& node.get(1) instanceof Language<?>
			&& (node.get(1) as Language<CTag>).tag.equals(CTag::LPAREN)
			
			&& node.get(2).is_GNode("Conditional")
			&& node.get(2).as_GNode.filter(PresenceCondition).reduce[pc1, pc2| pc1.or(pc2)].isTrue
			
			&& node.get(3).is_GNode("CompoundStatement") 
		) {
			val cond = node.get(2).as_GNode
			
			var update = true
			val newCond = GNode::create("Conditional", true)
			for (PresenceCondition pc : cond.filter(PresenceCondition)) {
				val children = cond.getChildrenGuardedBy(pc)
				if (
					children.last instanceof Language<?>
					&& (children.last as Language<CTag>).tag.equals(CTag::RPAREN)
				) {
					newCond
						.add(pc)
						.addAll(children.filterIndexed[c, i | i != children.size-1].toPair)
				} else {
					update = false
				}
			}
			
			if (update) {
				return GNode::createFromPair(
					"SelectionStatement",
					new Pair<Object>(new Language<CTag>(CTag::^IF))
						.add(new Language<CTag>(CTag::LPAREN))
						.add(newCond)
						.add(new Language<CTag>(CTag::RPAREN))
						.append(node.toPair.tail.tail.tail)
					)
			}
		}
		
		node
	}

}
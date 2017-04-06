package dk.itu.models.rules.phase1normalize

import dk.itu.models.rules.Rule
import xtc.lang.cpp.CTag
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.tree.GNode
import xtc.util.Pair

import static extension dk.itu.models.Extensions.*

class EnforceBracesInSelectionStatementRule extends Rule {
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
		
		if (node.name.equals("SelectionStatement")) {
			var update = false
			
			var branchStartIncl = node.indexOf(node.findFirst[toString.equals(")")]) + 1
			var newPair = node.toPair.subPair(0, branchStartIncl)
			
			if (node.exists[it instanceof Language<?> && (it as Language<CTag>).tag.equals(CTag::^ELSE)]) {
				
				var branchEndExcl = node.indexOf(node.findFirst[it instanceof Language<?> && (it as Language<CTag>).tag.equals(CTag::^ELSE)])
				
				val Pair<Object> branchChildren = node.toPair.subPair(branchStartIncl, branchEndExcl)
				
				if (
					(
						branchChildren.size == 1
						&& (branchChildren.head.is_GNode("SelectionStatement") || branchChildren.head.is_GNode("Conditional"))
					) || (
						branchChildren.size > 1
						&& (!(branchChildren.head instanceof Language<?>)
							|| (branchChildren.head as Language<CTag>).tag.equals(CTag::LBRACE)))
				) {		
					update = true
					newPair = newPair
						.add(GNode::createFromPair(
							"CompoundStatement",
							new Pair<Object>(new Language<CTag>(CTag::LBRACE))
								.append(branchChildren)
								.add(new Language<CTag>(CTag::RBRACE))))
						.add(new Language<CTag>(CTag::^ELSE))
				} else {
					newPair = newPair.append(branchChildren)
						.add(new Language<CTag>(CTag::^ELSE))
				}
				
				branchStartIncl = branchEndExcl + 1
			}
			
			var branchEndExcl = node.size
			val Pair<Object> branchChildren = node.toPair.subPair(branchStartIncl, branchEndExcl)
			
			if (
				(
					branchChildren.size == 1
					&& (branchChildren.head.is_GNode("SelectionStatement") || branchChildren.head.is_GNode("Conditional"))
				) || (
					branchChildren.size > 1
					&& (!(branchChildren.head instanceof Language<?>)
						|| (branchChildren.head as Language<CTag>).tag.equals(CTag::LBRACE)))
			) {
				
			
				update = true
				newPair.add(GNode::createFromPair(
					"CompoundStatement",
					new Pair<Object>(new Language<CTag>(CTag::LBRACE))
						.append(branchChildren)
						.add(new Language<CTag>(CTag::RBRACE))))
			} else {
				newPair = newPair.append(branchChildren)
			}
			
			if (update) {
				return GNode::createFromPair(
					"SelectionStatement",
					newPair
				)
			}
		}
		node
	}
}
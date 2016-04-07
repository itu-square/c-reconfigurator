package dk.itu.models.rules.normalize

import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.lang.cpp.CTag
import xtc.tree.GNode
import xtc.util.Pair
import static extension dk.itu.models.Extensions.*
import xtc.tree.Node
import dk.itu.models.strategies.TopDownStrategy
import dk.itu.models.rules.normalize.RemOneRule
import dk.itu.models.rules.normalize.RemZeroRule
import dk.itu.models.rules.normalize.SplitConditionalRule
import dk.itu.models.rules.normalize.ConstrainNestedConditionalsRule
import dk.itu.models.rules.normalize.ConditionPushDownRule
import dk.itu.models.rules.normalize.MergeSequentialMutexConditionalRule
import dk.itu.models.rules.normalize.MergeConditionalsRule
import dk.itu.models.rules.normalize.OptimizeAssignmentExpressionRule
import dk.itu.models.rules.Rule

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
//			println
//			println
//			println
//			println('''-------------------------------''')
//			println('''- EnforceBraces ---------------''')
//			println('''----------------''')
//			println(node.printCode)
//			println('''- i1: «node.findFirst[toString.equals(")")]»''')
//			println('''- i1: «node.indexOf(node.findFirst[toString.equals(")")])»''')
//			println('''- i2: «node.findFirst[it instanceof Language && (it as Language<CTag>).tag.equals(CTag::^ELSE)]»''')
//			println('''- i2: «node.indexOf(node.findFirst[it instanceof Language && (it as Language<CTag>).tag.equals(CTag::^ELSE)])»''')
			
			var i1 = node.indexOf(node.findFirst[toString.equals(")")])
			var i2 = node.indexOf(node.findFirst[it instanceof Language && (it as Language<CTag>).tag.equals(CTag::^ELSE)])
			var update = false
			var newPair = node.toPair.subPair(0, i1+1)
			
			if (i2 != -1) {
				val Pair<Object> children = node.toPair.subPair(i1+1, i2)
//				println('''---''')
//				children.forEach[println(it.printCode)]
				
				if (
					children.size > 1
					&& (!(children.head instanceof Language)
						|| (children.head as Language<CTag>).tag.equals(CTag::LBRACE))
				) {
//					println(''':> children''')
					update = true
					newPair.add(GNode::createFromPair(
						"CompoundStatement",
						new Pair<Object>(new Language<CTag>(CTag::LBRACE))
							.append(children)
							.add(new Language<CTag>(CTag::RBRACE))
							.add(new Language<CTag>(CTag::^ELSE))))
				}
				
				i1 = i2
				i2 = node.size
			}
			else {
				i2 = node.size
			}
			
			val Pair<Object> children = node.toPair.subPair(i1+1, i2)
//			println('''---''')
//			children.forEach[println(it.printCode)]
			
			if (
				children.size > 1
				&& (!(children.head instanceof Language)
					|| (children.head as Language<CTag>).tag.equals(CTag::LBRACE))
			) {
//				println(''':> children''')
				update = true
				var newChildren = new Pair<Object>(new Language<CTag>(CTag::LBRACE))
				newChildren = newChildren.append(children)
				newChildren.add(new Language<CTag>(CTag::RBRACE))
				
				newPair.add(GNode::createFromPair(
					"CompoundStatement",
					newChildren))
			}
			
			if (update) {
//				println
//				println
//				println
//				println
//				println("-----------------------------")
//				println(node.printAST)
//				println("-----------------------------")
//				println(GNode::createFromPair(
//					"SelectionStatement",
//					newPair
//				).printAST)
				
				return GNode::createFromPair(
					"SelectionStatement",
					newPair
				)
			}
		}
		
		node
	}
}
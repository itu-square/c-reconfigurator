package dk.itu.models.rules.phase1normalize

import dk.itu.models.rules.AncestorGuaranteedRule
import xtc.lang.cpp.CTag
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.tree.GNode
import xtc.util.Pair

import static extension dk.itu.models.Extensions.*

class SplitMultipleVariablesRule extends AncestorGuaranteedRule {
	
	override dispatch PresenceCondition transform(PresenceCondition cond) {
		cond
	}

	override dispatch Language<CTag> transform(Language<CTag> lang) {
		lang
	}

	override dispatch Pair<Object> transform(Pair<Object> pair) {
		
		if (!pair.empty
			&& pair.head.is_GNode("Declaration")
			&& pair.head.as_GNode.get(0).is_GNode("DeclaringList")
			&& pair.head.as_GNode.get(0).as_GNode.get(0).is_GNode("DeclaringList")
		) {
			val innermostDeclaringList = getInnermostDeclaringList(pair.head.as_GNode).as_GNode
			val declaringList = pair.head.as_GNode.get(0).as_GNode
			
			val arrayDeclarator = declaringList.findFirst[it.is_GNode("ArrayDeclarator")]
				
			val unaryIdentifierDeclarator = declaringList.findFirst[it.is_GNode("UnaryIdentifierDeclarator")]
				
			val simpleDeclarator = declaringList.findFirst[it.is_GNode("SimpleDeclarator")]
			
			val declarator =
				if (arrayDeclarator !== null)
					arrayDeclarator
				else if (unaryIdentifierDeclarator !== null)
					unaryIdentifierDeclarator
				else if (simpleDeclarator !== null)
					simpleDeclarator
				else {
					println
					println("----- SplitMultipleVariablesRule -----------------")
					println(pair.head.as_GNode.printAST)
					throw new Exception("SplitMultipleVariableRule: unknown variable name.")
				}
			return
				new Pair<Object>(
					GNode::create(
						"Declaration",
						declaringList.get(0),
						new Language<CTag>(CTag::SEMICOLON)
					)
				)	
				.add(
					GNode::create(
						"Declaration",
						GNode::create(
							"DeclaringList",
							innermostDeclaringList.get(0), // gets type
							declarator,
							new Language<CTag>(CTag::SEMICOLON)
						)
					)
				)
				.append(pair.tail)
		}
		
		pair
	}
	
	override dispatch Object transform(GNode node) {		
		node
	}
	
	/*
	 * This helper method returns the innermost DeclaringList node 
	 * in a multiple variable declaration
	 */
	def getInnermostDeclaringList(GNode node) {
		
		var innermost = node
		
		while(!innermost.empty && innermost.get(0).is_GNode("DeclaringList")) {
			innermost = innermost.get(0).as_GNode
		}
		innermost
	}
}
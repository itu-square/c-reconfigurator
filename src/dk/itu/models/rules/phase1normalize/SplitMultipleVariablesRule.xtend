package dk.itu.models.rules.phase1normalize

import dk.itu.models.rules.AncestorGuaranteedRule
import xtc.lang.cpp.CTag
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.lang.cpp.Syntax.Text
import xtc.tree.GNode
import xtc.util.Pair

class SplitMultipleVariablesRule extends AncestorGuaranteedRule {
	
	override dispatch PresenceCondition transform(PresenceCondition cond) {
		cond
	}

	override dispatch Language<CTag> transform(Language<CTag> lang) {
		lang
	}

	override dispatch Pair<Object> transform(Pair<Object> pair) {
		
		if (!pair.empty
			&& pair.head instanceof GNode
			&& (pair.head as GNode).name.equals("Declaration")
			
			&& (pair.head as GNode).get(0) instanceof GNode
			&& ((pair.head as GNode).get(0) as GNode).name.equals("DeclaringList")
			
			&& ((pair.head as GNode).get(0) as GNode).get(0) instanceof GNode
			&& (((pair.head as GNode).get(0) as GNode).get(0) as GNode).name.equals("DeclaringList")
		) {
			val innermostDeclaringList = getInnermostDeclaringList((pair.head as GNode)) as GNode
			val declaringList = (pair.head as GNode).get(0) as GNode
		
			val varName =
				if (declaringList.get(1) instanceof GNode && (declaringList.get(1) as GNode).name.equals("SimpleDeclarator"))
					
					(declaringList.get(1) as GNode).get(0).toString
				
				else if ((declaringList.get(0) as GNode).name.equals("DeclaringList") 
					&& declaringList.get(1) instanceof Language
					&& (declaringList.get(2) as GNode).name.equals("SimpleDeclarator"))
					
					(declaringList.get(2) as GNode).get(0).toString
				
				else 
					throw new Exception("SplitMultipleVariableRule: unknown variable name.")
			
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
							GNode::create("SimpleDeclarator", new Text(CTag::IDENTIFIER, varName)),
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
		
		while(!innermost.empty && innermost.get(0) instanceof GNode 
			&& (innermost.get(0) as GNode).name.equals("DeclaringList")
		) {
			innermost = innermost.get(0) as GNode
		}
		innermost
	}
}
package dk.itu.models.rules.phase1normalize

import dk.itu.models.rules.AncestorGuaranteedRule
import xtc.lang.cpp.CTag
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.lang.cpp.Syntax.Text
import xtc.tree.GNode
import xtc.util.Pair

import static extension dk.itu.models.Extensions.*

class ExtractInitializerRule extends AncestorGuaranteedRule {
	
	override dispatch PresenceCondition transform(PresenceCondition cond) {
		cond
	}

	override dispatch Language<CTag> transform(Language<CTag> lang) {
		lang
	}

	override dispatch Pair<Object> transform(Pair<Object> pair) {
		
		if (
			!pair.empty
			
			&& pair.head.is_GNode("Declaration")
			&& ancestors.exists[anc | anc.name.equals("FunctionDefinition")]
			
			&& pair.head.as_GNode.get(0).is_GNode("DeclaringList")
			
			&& pair.head.as_GNode.get(0).as_GNode.filter(GNode).exists[name.equals("InitializerOpt")]
			&& pair.head.as_GNode.get(0).as_GNode.filter(GNode).findFirst[name.equals("InitializerOpt")].size > 0
		) {
			
			val declaringList = pair.head.as_GNode.get(0).as_GNode
						
			val varName = declaringList.getDescendantNode("SimpleDeclarator").get(0).toString
			val initializer = declaringList.getDescendantNode("Initializer")
			
			var Pair<Object> newPair = Pair::EMPTY.add(pair.head.as_GNode.removeNode[ it.is_GNode("InitializerOpt") ])
			
			if (
				initializer.getDescendantNode[ it.is_Text(CTag::STRINGliteral) ] !== null
			) {
				var str = initializer.get(0).as_GNode.getDescendantNode[ it.is_Text(CTag::STRINGliteral) ].toString
				str = str.subSequence(1, str.length-1).toString
				for (var int index = 0; index < str.length; index++) {
					newPair = newPair.add(buildAssignment(varName, index.toString, new Text<CTag>(CTag::CHARACTERconstant, "'" + str.charAt(index) + "'")))
				}
			} else if (
				initializer.get(0) instanceof Language<?>
				&& (initializer.get(0) as Language<CTag>).tag.equals(CTag::LBRACE)
				
				&& initializer.get(1).is_GNode("MatchedInitializerList")
				
				&& initializer.get(2).is_GNode("Initializer")
				
				&& initializer.get(2).as_GNode.get(0) instanceof Text<?>
				&& (initializer.get(2).as_GNode.get(0) as Text<CTag>).tag.equals(CTag::OCTALconstant)
				&& (initializer.get(2).as_GNode.get(0) as Text<CTag>).toString.equals("0")
				
				&& initializer.get(3) instanceof Language<?>
				&& (initializer.get(3) as Language<CTag>).tag.equals(CTag::RBRACE)
				
				&& declaringList.getDescendantNode("ArrayAbstractDeclarator") !== null
			) {
				val newDeclaration = 
					GNode::create("Declaration",
						GNode::create("DeclaringList",
							new Language<CTag>(CTag::INT),
							GNode::create("SimpleDeclarator",
								new Text<CTag>(CTag::IDENTIFIER, '''_reconfig_«varName»_index'''))),
						new Language<CTag>(CTag::SEMICOLON))
				newDeclaration.location = pair.head.as_GNode.getDescendantNode[it.location !== null].location
				
				newPair = newPair.add(newDeclaration)
						
				newPair = newPair.add(
					GNode::createFromPair("IterationStatement",
						Pair::EMPTY
							.add(new Language<CTag>(CTag::^FOR))
							.add(new Language<CTag>(CTag::LPAREN))
							.add(GNode::create("AssignmentExpression",
								GNode::create("PrimaryIdentifier",
									new Text<CTag>(CTag::IDENTIFIER, '''_reconfig_«varName»_index''')),
								GNode::create("AssignmentOperator",
									new Language<CTag>(CTag::ASSIGN)),
								new Text<CTag>(CTag::OCTALconstant, "0")))
							.add(new Language<CTag>(CTag::SEMICOLON))
							.add(GNode::create("RelationalExpression",
								GNode::create("PrimaryIdentifier",
									new Text<CTag>(CTag::IDENTIFIER, '''_reconfig_«varName»_index''')),
								new Language<CTag>(CTag::LT),
								declaringList.getDescendantNode("ArrayAbstractDeclarator").get(1)))
							.add(new Language<CTag>(CTag::SEMICOLON))
							.add(GNode::create("Increment",
								GNode::create("PrimaryIdentifier",
									new Text<CTag>(CTag::IDENTIFIER, '''_reconfig_«varName»_index''')),
								new Language<CTag>(CTag::ICR)))
							.add(new Language<CTag>(CTag::RPAREN))
							.add(GNode::create("CompoundStatement",
								new Language<CTag>(CTag::LBRACE),
								GNode::create("DeclarationOrStatementList",
									buildAssignment(varName, '''_reconfig_«varName»_index''', new Text<CTag>(CTag::OCTALconstant, "0"))),
								new Language<CTag>(CTag::RBRACE)))
					)
				)
			} else {
				newPair = newPair.add(GNode::create(
							"ExpressionStatement",
							GNode::create(
								"AssignmentExpression",
								GNode::create("PrimaryIdentifier", new Text(CTag::IDENTIFIER, varName)),
								GNode::create("AssignmentOperator", new Language<CTag>(CTag::ASSIGN)),
								initializer.get(0)),
							new Language<CTag>(CTag::SEMICOLON)
						))
			}
				
			newPair = newPair.append(pair.tail)
			
			return newPair
		} else {
			return pair
		}
	}
	
	override dispatch Object transform(GNode node) {		
		node
	}
	
}
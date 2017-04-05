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
			&& pair.head instanceof GNode
			&& (pair.head as GNode).name.equals("Declaration")
			&& ancestors.exists[anc | anc.name.equals("FunctionDefinition")]
			
			&& (pair.head as GNode).get(0) instanceof GNode
			&& ((pair.head as GNode).get(0) as GNode).name.equals("DeclaringList")
			
			&& ((pair.head as GNode).get(0) as GNode).filter(GNode).exists[name.equals("InitializerOpt")]
			&& ((pair.head as GNode).get(0) as GNode).filter(GNode).findFirst[name.equals("InitializerOpt")].size > 0
		) {
			
			val declaringList = (pair.head as GNode).get(0) as GNode
						
			val varName = declaringList.getDescendantNode("SimpleDeclarator").get(0).toString
			val initializer = declaringList.filter(GNode).findFirst[name.equals("InitializerOpt")].get(1) as GNode
			
			var Pair<Object> newPair =
				new Pair<Object>(
					GNode::createFromPair(
						"Declaration",
						(pair.head as GNode).map[c | 
							if (!(c instanceof GNode) || !(c as GNode).name.equals("DeclaringList")) c
							else GNode::createFromPair(
								"DeclaringList",
								(c as GNode).filter[d | !(d instanceof GNode) || !(d as GNode).name.equals("InitializerOpt")].toPair)
						].toPair))
			
			if (
				initializer.get(0) instanceof GNode
				&& (initializer.get(0) as GNode).name.equals("StringLiteralList")
			) {
				val stringLiteralList = initializer.get(0) as GNode
				if (
					stringLiteralList.size == 1
					&& stringLiteralList.getDescendantNode[
						it instanceof Text<?> && (it as Text<CTag>).tag.equals(CTag::STRINGliteral)
					] != null
				) {
					var str = stringLiteralList.getDescendantNode[
						it instanceof Text<?> && (it as Text<CTag>).tag.equals(CTag::STRINGliteral)].toString
					str = str.subSequence(1, str.length-1).toString
					for (var int index = 0; index < str.length; index++) {
						newPair = newPair.add(GNode::create(
									"ExpressionStatement",
									GNode::create(
										"AssignmentExpression",
										GNode::create(
											"Subscript",
											GNode::create("PrimaryIdentifier", new Text(CTag::IDENTIFIER, varName)),
											new Language<CTag>(CTag::LBRACK),
											new Text<CTag>(CTag::INTEGERconstant, index.toString),
											new Language<CTag>(CTag::RBRACK)
											),
										GNode::create("AssignmentOperator", new Language<CTag>(CTag::ASSIGN)),
										new Text<CTag>(CTag::CHARACTERconstant, "'" + str.charAt(index) + "'")),
									new Language<CTag>(CTag::SEMICOLON)
								))
					}
				}
				else {
					println
					println(declaringList.printCode)
					println("-----")
					println(declaringList.printAST)
					println("-----")
					println(stringLiteralList.printAST)
					throw new Exception("ExtractInitializerRule: unknown String Literal initialization pattern.")
				}
			} else if (
				initializer.get(0) instanceof Language<?>
				&& (initializer.get(0) as Language<CTag>).tag.equals(CTag::LBRACE)
				
				&& initializer.get(1) instanceof GNode
				&& (initializer.get(1) as GNode).name.equals("MatchedInitializerList")
				
				&& initializer.get(2) instanceof GNode
				&& (initializer.get(2) as GNode).name.equals("Initializer")
				
				&& (initializer.get(2) as GNode).get(0) instanceof Text<?>
				&& ((initializer.get(2) as GNode).get(0) as Text<CTag>).tag.equals(CTag::OCTALconstant)
				&& ((initializer.get(2) as GNode).get(0) as Text<CTag>).toString.equals("0")
				
				&& initializer.get(3) instanceof Language<?>
				&& (initializer.get(3) as Language<CTag>).tag.equals(CTag::RBRACE)
				
				&& declaringList.getDescendantNode("ArrayAbstractDeclarator") != null
			) {
				val newDeclaration = 
					GNode::create("Declaration",
						GNode::create("DeclaringList",
							new Language<CTag>(CTag::INT),
							GNode::create("SimpleDeclarator",
								new Text<CTag>(CTag::IDENTIFIER, '''_reconfig_«varName»_index'''))),
						new Language<CTag>(CTag::SEMICOLON))
				newDeclaration.location = (pair.head as GNode).getDescendantNode[it.location != null].location
				
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
									GNode::create("ExpressionStatement",
										GNode::create("AssignmentExpression",
											GNode::create("Subscript",
												GNode::create("PrimaryIdentifier",
													new Text<CTag>(CTag::IDENTIFIER, varName),
													new Language<CTag>(CTag::LBRACK),
													GNode::create("PrimaryIdentifier",
														new Text<CTag>(CTag::IDENTIFIER, '''_reconfig_«varName»_index''')),
													new Language<CTag>(CTag::RBRACK)
												)
											),
											GNode::create("AssignmentOperator",
												new Language<CTag>(CTag::ASSIGN)),
											new Text<CTag>(CTag::OCTALconstant, "0")),
										new Language<CTag>(CTag::SEMICOLON))),
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
		}
		
		pair
	}
	
	override dispatch Object transform(GNode node) {		
		node
	}
	
}
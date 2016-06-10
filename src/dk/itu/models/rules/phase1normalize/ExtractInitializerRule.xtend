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
					&& stringLiteralList.get(0) instanceof GNode
					&& (stringLiteralList.get(0) as GNode).name.equals("Conditional")
					&& (stringLiteralList.get(0) as GNode).size == 2
					&& (stringLiteralList.get(0) as GNode).get(1) instanceof Text<?>
					&& ((stringLiteralList.get(0) as GNode).get(1) as Text<CTag>).tag.equals(CTag::STRINGliteral)
				) {
					var str = (stringLiteralList.get(0) as GNode).get(1).toString
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
					println(stringLiteralList.printAST)
					throw new Exception("ExtractInitializerRule: unknown String Literal initialization pattern.")
				}
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
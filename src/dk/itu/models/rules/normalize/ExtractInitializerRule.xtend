package dk.itu.models.rules.normalize

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
			val varName =
				if ((declaringList.get(1) as GNode).name.equals("SimpleDeclarator"))
					(declaringList.get(1) as GNode).get(0).toString
				else ((declaringList.get(1) as GNode).get(1) as GNode).get(0).toString
			val initializer = declaringList.filter(GNode).findFirst[name.equals("InitializerOpt")].get(1) as GNode
			
			return
				new Pair<Object>(
					GNode::createFromPair(
						"Declaration",
						(pair.head as GNode).map[c | 
							if (!(c instanceof GNode) || !(c as GNode).name.equals("DeclaringList")) c
							else GNode::createFromPair(
								"DeclaringList",
								(c as GNode).filter[d | !(d instanceof GNode) || !(d as GNode).name.equals("InitializerOpt")].toPair)
						].toPair))
				.add(GNode::create(
					"ExpressionStatement",
					GNode::create(
						"AssignmentExpression",
						GNode::create("PrimaryIdentifier", new Text(CTag::IDENTIFIER, varName)),
						GNode::create("AssignmentOperator", new Language<CTag>(CTag::ASSIGN)),
						initializer.get(0)),
					new Language<CTag>(CTag::SEMICOLON)
				))
				.append(pair.tail)
		}
		
		pair
	}
	
	override dispatch Object transform(GNode node) {		
		node
	}
	
}
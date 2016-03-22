package dk.itu.models.rules

import java.util.Collection
import xtc.lang.cpp.CTag
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.lang.cpp.Syntax.Text
import xtc.tree.GNode
import xtc.util.Pair
import java.util.HashMap
import java.util.List
import dk.itu.models.Reconfigurator
import static extension dk.itu.models.Extensions.*
import xtc.tree.Node

class Ifdef2IfRule extends AncestorGuaranteedRule {
	
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
		if (node.name == "Conditional") {
			var featureExpr = (node.get(0) as PresenceCondition).toString
			var transformedFeatureExpr = Reconfigurator.preprocessor.getTransformedFeatureExpr(featureExpr)
			
			ancestors.add(node)
			
			val newNode = GNode::create("SelectionStatement")
			newNode.addAll(#[
				new Language<CTag>(CTag.^IF),
				new Language<CTag>(CTag.LPAREN),
				GNode.create("PrimaryIdentifier", new Text<CTag>(CTag.OCTALconstant, transformedFeatureExpr)),
				new Language<CTag>(CTag.RPAREN),
				new Language<CTag>(CTag.LBRACE)
			] as List<Node>)
			newNode.addAll(node.toPair.tail)
			newNode.add(new Language<CTag>(CTag.RBRACE))
			
			ancestors.remove(node)

			newNode
		} else {
			ancestors.add(node)

			val newNode = GNode::create(node.name)
			node.forEach[newNode.add(it)]

			ancestors.remove(node)

			newNode
		}
	}

}
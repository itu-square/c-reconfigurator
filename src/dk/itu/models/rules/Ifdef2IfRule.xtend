package dk.itu.models.rules

import xtc.lang.cpp.CTag
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.tree.GNode
import xtc.util.Pair
import xtc.lang.cpp.Syntax.Text
import java.util.Collection

class Ifdef2IfRule extends Rule {
	
	override dispatch PresenceCondition transform(PresenceCondition cond) {
		cond
	}

	override dispatch Language<CTag> transform(Language<CTag> lang) {
		lang
	}

	override dispatch Pair<?> transform(Pair<?> pair) {
		pair
	}
	
	override dispatch Object transform(GNode node) {
		if (node.name == "Conditional" && node.size == 4 &&
			(node.get(0) as PresenceCondition).not.toString == (node.get(2) as PresenceCondition).toString &&
			(node.get(0) as PresenceCondition).toString.startsWith("!(defined")) {

			var defined = (node.get(0) as PresenceCondition).toString
			var variable = defined.substring(defined.indexOf(' ') + 1, defined.indexOf(')'))

			ancestors.add(node)
			
			val newNode = GNode::create("SelectionStatement")
			newNode.addAll(#[
				new Language<CTag>(CTag.^IF),
				new Language<CTag>(CTag.LPAREN),
				GNode.create("PrimaryIdentifier", new Text<CTag>(CTag.OCTALconstant, variable)),
				new Language<CTag>(CTag.RPAREN),
				node.get(1),
				new Language<CTag>(CTag.^ELSE),
				node.get(3)
			] as Collection<Object>)

			ancestors.remove(node)
			
			newNode
		} else if (node.name == "Conditional" && node.size == 2) {
				
			var defined = (node.get(0) as PresenceCondition).toString
			var variable = defined.substring(defined.indexOf(' ') + 1, defined.indexOf(')'))

			ancestors.add(node)

			val newNode = GNode::create("SelectionStatement")
			newNode.addAll(#[
				new Language<CTag>(CTag.^IF),
				new Language<CTag>(CTag.LPAREN),
				GNode.create("PrimaryIdentifier", new Text<CTag>(CTag.OCTALconstant, variable)),
				new Language<CTag>(CTag.RPAREN),
				new Language<CTag>(CTag.LBRACE),
				node.get(1),
				new Language<CTag>(CTag.RBRACE)
			] as Collection<Object>)

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
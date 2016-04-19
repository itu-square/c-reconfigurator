package dk.itu.models.rules.phase6ifdefs

import dk.itu.models.Reconfigurator
import net.sf.javabdd.BDD
import xtc.lang.cpp.CTag
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.lang.cpp.Syntax.Text
import xtc.tree.GNode
import xtc.util.Pair

import static extension dk.itu.models.Extensions.*

class Ifdef2IfRule extends dk.itu.models.rules.AncestorGuaranteedRule {
	
	// TODO: move to Extensions and minimize
	def cexp(BDD bdd) {
		val vars = Reconfigurator.presenceConditionManager.variableManager
		
		// unused yet
//      if (bdd.isOne()) {
//        print("1");
//        return;
//      } else if (bdd.isZero()) {
//        print("0");
//        return;
//      }
		
		var GNode disj;
		var firstConjunction = true;
		for (Object o : bdd.allsat()) {
//			if (!firstConjunction) { print(" || "); } 

			var byte[] sat = o as byte[];
			var GNode conj;
			var Boolean firstTerm = true;
			for (var i = 0; i < sat.length; i++) {
//				if (sat.get(i) >= 0 && ! firstTerm) { print(" && "); }
				switch (sat.get(i)) {
					case 0 as byte: {
//						print("!")
						var id = vars.getName(i)
						id = id.substring(9, id.length-1)
						id = Reconfigurator.transformedFeaturemap.get(id)
						var term = GNode::create("UnaryExpression",
							GNode::create("Unaryoperator", new Language<CTag>(CTag.NOT)),
							GNode::create("PrimaryIdentifier", new Text<CTag>(CTag.IDENTIFIER, id)))
						
						if(firstTerm) { conj = term }
						else { conj = GNode::create("LogicalAndExpression", conj, new Language<CTag>(CTag.ANDAND), term) }
						firstTerm = false
					}
					case 1 as byte: {
						var id = vars.getName(i)
						id = id.substring(9, id.length-1)
						id = Reconfigurator.transformedFeaturemap.get(id)
//						print(id)
						var term = GNode::create("PrimaryIdentifier", new Text<CTag>(CTag.IDENTIFIER, id))
						
						if(firstTerm) { conj = term }
						else { conj = GNode::create("LogicalAndExpression", conj, new Language<CTag>(CTag.ANDAND), term) }
						firstTerm = false
					}
				}
			}
			if(firstConjunction) { disj = conj }
			else { disj = GNode::create("LogicalORExpression", disj, new Language<CTag>(CTag.OROR), conj) }
        	firstConjunction = false;
		}
		
		GNode::create("PrimaryExpression",
				new Language<CTag>(CTag.LPAREN),
				disj,
				new Language<CTag>(CTag.RPAREN))
    }
	
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
		
		if (
//			node.name.equals("Conditional")
//			&& #["AdditiveExpression"].contains(node.name)
//		) {
//			GNode::create("PrimaryExpression",
//				new Language<CTag>(CTag.LPAREN),
//		 		GNode::create("ConditionalExpression",
//		 			pc.getBDD.cexp,
//		 			new Language<CTag>(CTag.QUESTION),
//		 			newExp,
//		 			new Language<CTag>(CTag.COLON),
//		 			exp
//		 			),
//		 		new Language<CTag>(CTag.RPAREN)
//			)
//		} else if (
			node.name.equals("Conditional")
			&& node.filter(PresenceCondition).size == 1
			&& #["DeclarationOrStatementList"].contains(ancestors.last.name)
		) {	
			return GNode::createFromPair(
				"SelectionStatement",
				new Pair<Object>(new Language<CTag>(CTag.^IF))
					.add(new Language<CTag>(CTag.LPAREN))
					.add((node.get(0) as PresenceCondition).BDD.cexp)
					.add(new Language<CTag>(CTag.RPAREN))
					.add(new Language<CTag>(CTag.LBRACE))
					.append(node.toPair.tail)
					.add(new Language<CTag>(CTag.RBRACE))
			)
		} else if (
			node.name.equals("Conditional")
		) {
			println
			ancestors.forEach[
				println('''- «it»''')]
			println(node.printAST)
			throw new Exception("Ifdef2IfRule: unexpected Conditional context")
		}
		
		node
	}

}
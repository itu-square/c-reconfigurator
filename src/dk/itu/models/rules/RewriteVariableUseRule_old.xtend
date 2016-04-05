package dk.itu.models.rules

import xtc.lang.cpp.CTag
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.tree.GNode
import xtc.util.Pair
import java.util.HashMap
import java.util.List
import xtc.lang.cpp.Syntax.Text
import net.sf.javabdd.BDD
import dk.itu.models.Reconfigurator
import xtc.lang.cpp.Syntax.LanguageTag

class RewriteVariableUseRule_old extends Rule {
	
	private val HashMap<PresenceCondition, String> pcidmap
	private val HashMap<String, List<PresenceCondition>> variableToPCMap
	
	new (HashMap<String, List<PresenceCondition>> fmap, HashMap<PresenceCondition, String> pcidmap) {
		this.variableToPCMap = fmap
		this.pcidmap = pcidmap
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
	
	def buildExp (String varName, List<PresenceCondition> conditions, Pair<?> args) {
		
		var exp = GNode::create("FunctionCall",
		 	GNode::create("PrimaryIdentifier", new Text(CTag.IDENTIFIER, "assert")),
		 	new Language<CTag>(CTag.LPAREN),
		 	GNode::create("ExpressionList", new Text(CTag.OCTALconstant, "0"),
		 	new Language<CTag>(CTag.RPAREN)))
		
		for (PresenceCondition pc : conditions.reverseView) {
			exp = GNode::create("PrimaryExpression",
				new Language<CTag>(CTag.LPAREN),
		 		GNode::create("ConditionalExpression",
		 			pc.BDD.cexp,
		 			new Language<CTag>(CTag.QUESTION),
		 			GNode::create("AssignmentExpression", //TODO: finish assign (left side usage)
		 				GNode::create("PrimaryIdentifier", new Text(CTag.IDENTIFIER, varName + "_V" + pcidmap.get_id(pc))),
		 				GNode::create("AssignmentOperator", new Text(CTag.ASSIGN, "=")),
		 				new Language<CTag>(CTag.INTEGERconstant)
		 				),
		 			new Language<CTag>(CTag.COLON),
		 			exp
		 			),
		 		new Language<CTag>(CTag.RPAREN)
			)
		}
		
		exp
	}
	
	override dispatch Object transform(GNode node) {
		if (node.name.equals("PrimaryIdentifier") 
			&& variableToPCMap.containsKey((node.get(0) as Text).toString)
		) {
			var varname = (node.get(0) as Text).toString

//			buildExp(varname, variableToPCMap.get(varname), node.toPair.tail)
			var exp = GNode::create("FunctionCall",
		 	GNode::create("PrimaryIdentifier", new Text(CTag.IDENTIFIER, "assert")),
		 	new Language<CTag>(CTag.LPAREN),
		 	GNode::create("ExpressionList", new Text(CTag.OCTALconstant, "0"),
		 	new Language<CTag>(CTag.RPAREN)))
		 	
		 	for (PresenceCondition pc : variableToPCMap.get(varname).reverseView) {
		 		exp = GNode::create("PrimaryExpression",
					new Language<CTag>(CTag.LPAREN),
		 			GNode::create("ConditionalExpression",
		 				pc.BDD.cexp,
		 				new Language<CTag>(CTag.QUESTION),
		 				GNode::create("AssignmentExpression", 
		 					GNode::create("PrimaryIdentifier", new Text(CTag.IDENTIFIER, varname + "_V" + pcidmap.get_id(pc)))),
		 				new Language<CTag>(CTag.COLON),
		 				exp
		 				),
		 			new Language<CTag>(CTag.RPAREN)
				)
		 	}
			
			exp
		} else {
			node
		}
	}
	
	static def String get_id (HashMap<PresenceCondition, String> map, PresenceCondition pc) {
		map.get(map.keySet.findFirst[is(pc)])
	}
	
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
//						print(id)
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

}
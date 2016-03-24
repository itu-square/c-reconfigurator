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
import static extension dk.itu.models.Extensions.*

class RewriteFunctionCallRule extends AncestorGuaranteedRule {
	
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
	
	private val HashMap<PresenceCondition, String> pcidmap
	static def String get_id (HashMap<PresenceCondition, String> map, PresenceCondition pc) {
		map.get(map.keySet.findFirst[is(pc)])
	}
	
	private val HashMap<String, List<PresenceCondition>> fmap
	
	new (HashMap<String, List<PresenceCondition>> fmap, HashMap<PresenceCondition, String> pcidmap) {
		this.fmap = fmap
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
	
	def buildExp (String fname, List<PresenceCondition> conditions, Pair<?> args, PresenceCondition guard) {
		
		var PresenceCondition disjunctionPC = null
		for (PresenceCondition pc : conditions.reverseView) {
			disjunctionPC = if (disjunctionPC == null) pc else pc.or(disjunctionPC)
		}
//		println("disj:> " + disjunctionPC)
//		println("grd :> " + guard)
//		println("impl:> " + guard.BDD.imp(disjunctionPC.BDD))
//		println("one :> " + guard.BDD.imp(disjunctionPC.BDD).isOne)
//		println("zero:> " + guard.BDD.imp(disjunctionPC.BDD).isZero)
//		println("!mp :> " + !guard.BDD.imp(disjunctionPC.BDD).isOne)
		
		if (!guard.BDD.imp(disjunctionPC.BDD).isOne)
			println('''Reconfigurator error: «fname» undefined under «disjunctionPC.not».''')
		
		var exp = if (guard.BDD.imp(disjunctionPC.BDD).isOne) null else
			GNode::create("FunctionCall",
		 	GNode::create("PrimaryIdentifier", new Text(CTag.IDENTIFIER, "_reconfig_undefined")),
		 	new Language<CTag>(CTag.LPAREN),
		 	GNode::create("ExpressionList", GNode::create("StringLiteralList", new Text(CTag.STRINGliteral, '''"«fname»"''')),
		 	new Language<CTag>(CTag.RPAREN)))
		
		for (PresenceCondition pc : conditions.reverseView) {
			val newCall = GNode::create("FunctionCall",
		 				GNode::create("PrimaryIdentifier", new Text(CTag.IDENTIFIER, fname + "_V" + pcidmap.get_id(pc))),
		 				GNode::createFromPair("ExpressionList", args));
			
			exp = if (exp == null) newCall else
			 GNode::create("PrimaryExpression",
				new Language<CTag>(CTag.LPAREN),
		 		GNode::create("ConditionalExpression",
		 			pc.BDD.cexp,
		 			new Language<CTag>(CTag.QUESTION),
		 			newCall,
		 			new Language<CTag>(CTag.COLON),
		 			exp
		 			),
		 		new Language<CTag>(CTag.RPAREN)
			)
		}
		
		exp
	}
	
	override dispatch Object transform(GNode node) {
		if (node.name.equals("FunctionCall")
			&& fmap.containsKey((node.get(0) as GNode).get(0).toString)
		) {
//			println("func:> " + node.printCode)
//			println("fmap:> " + fmap.size)
//			fmap.forEach[k, v| println("fmap:> " + k + " " + v)]
//			println("grd :> " + node.guard)
//			println("name:> " + (node.get(0) as GNode).get(0).toString)
//			println(fmap.containsKey((node.get(0) as GNode).get(0).toString))

			val fcall = (node.get(0) as GNode).get(0).toString
			val newExp = buildExp(fcall, fmap.get(fcall), node.toPair.tail, node.guard)
//			println("exp :> " +	if (newExp == null) "null" else newExp.printCode)
//			println
			return newExp
		}
		node
	}

}
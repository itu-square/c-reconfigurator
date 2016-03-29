package dk.itu.models.rules

import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.lang.cpp.CTag
import xtc.util.Pair
import xtc.tree.GNode
import static extension dk.itu.models.Extensions.*
import java.util.ArrayList
import java.util.AbstractMap.SimpleEntry
import java.util.HashMap
import java.util.List
import xtc.lang.cpp.Syntax.Text
import dk.itu.models.Reconfigurator
import net.sf.javabdd.BDD

class RewriteVariableUseRule extends AncestorGuaranteedRule {
	
	private val HashMap<PresenceCondition, String> pcidmap
	protected val ArrayList<SimpleEntry<GNode,HashMap<String, List<PresenceCondition>>>> localVariableScopes
	
	protected val PresenceCondition externalGuard
	
	new (ArrayList<SimpleEntry<GNode,HashMap<String, List<PresenceCondition>>>> localVariableScopes, PresenceCondition externalGuard, HashMap<PresenceCondition, String> pcidmap) {
		super()
		this.localVariableScopes = localVariableScopes
		this.externalGuard = externalGuard
		this.pcidmap = pcidmap
	}
	
	protected def variableExists(String name) {
		localVariableScopes.exists[ scope |
			scope.value.keySet.contains(name)
		]
	}
	
	static def String get_id (HashMap<PresenceCondition, String> map, PresenceCondition pc) {
		map.get(map.keySet.findFirst[is(pc)])
	}
	
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
    
	protected def buildExp(String name) {
		var GNode exp = null
		
		val last = localVariableScopes.findLast[ scope |
			scope.value.keySet.contains(name)
		]
		
		if (last != null) {
			val conditions = last.value.get(name)
			var PresenceCondition disjunctionPC = null
			for (PresenceCondition pc : conditions.reverseView) {
				disjunctionPC = if (disjunctionPC == null) pc else pc.or(disjunctionPC)
			}
		
			if (!externalGuard.BDD.imp(disjunctionPC.BDD).isOne)
				println('''Reconfigurator error: «name» undefined under «disjunctionPC.not».''')
		
			exp = if (externalGuard.BDD.imp(disjunctionPC.BDD).isOne) null else
				GNode::create("FunctionCall",
			 	GNode::create("PrimaryIdentifier", new Text(CTag.IDENTIFIER, "_reconfig_undefined")),
			 	new Language<CTag>(CTag.LPAREN),
			 	GNode::create("ExpressionList", GNode::create("StringLiteralList", new Text(CTag.STRINGliteral, '''"«name»"''')),
			 	new Language<CTag>(CTag.RPAREN)))
			
			for (PresenceCondition pc : conditions.reverseView) {
				val newExp = GNode::create("PrimaryIdentifier", new Text(CTag.IDENTIFIER, name + "_V" + pcidmap.get_id(pc)));
				
				exp = if (exp == null) newExp else
				 GNode::create("PrimaryExpression",
					new Language<CTag>(CTag.LPAREN),
			 		GNode::create("ConditionalExpression",
			 			pc.BDD.cexp,
			 			new Language<CTag>(CTag.QUESTION),
			 			newExp,
			 			new Language<CTag>(CTag.COLON),
			 			exp
			 			),
			 		new Language<CTag>(CTag.RPAREN)
				)
			}
		}
		exp
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
		if (node.name.equals("PrimaryIdentifier")
			&& variableExists((node.get(0) as Language<CTag>).toString)
		) {
			var varname = (node.get(0) as Language<CTag>).toString
			println
			println('''::> «varname» («ancestors.head.printCode»)''')
			println('''contains: «variableExists((node.get(0) as Language<CTag>).toString)»''')
			println('''externalGuard: «externalGuard.PCtoCPPexp»''')
			val newExp = buildExp((node.get(0) as Language<CTag>).toString)
			if (newExp != null) {
				println('''newExp: «newExp.printCode»''')
				return newExp
			}
		} else if (node.name.equals("AssignmentExpression")) {
			
		}
		node
	}
}
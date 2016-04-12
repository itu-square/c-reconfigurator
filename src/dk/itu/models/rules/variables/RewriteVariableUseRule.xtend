package dk.itu.models.rules.variables

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
import dk.itu.models.strategies.TopDownStrategy

class RewriteVariableUseRule extends dk.itu.models.rules.AncestorGuaranteedRule {
	
	private val HashMap<PresenceCondition, String> pcidmap
	protected val ArrayList<SimpleEntry<GNode,HashMap<String, List<PresenceCondition>>>> localVariableScopes
	
	protected val PresenceCondition externalGuard
	
	new (
		ArrayList<SimpleEntry<GNode,HashMap<String, List<PresenceCondition>>>> localVariableScopes,
		PresenceCondition externalGuard,
		HashMap<PresenceCondition, String> pcidmap
	) {
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
    

    
    private def replaceTextWithVarName (GNode node, String varName) {
    	val tdn = new TopDownStrategy
    	tdn.register(new dk.itu.models.rules.ReplaceIdentifiersRule(varName))
    	tdn.transform(node) as GNode
    }
    
	protected def buildExp(GNode node, String varName, PresenceCondition varPC, List<PresenceCondition> declarationPCs) {
		
		if (declarationPCs.empty) { // there are no declarations of this variable
			return null
		} else {
			
			// compute the disjunction of all declaration PCs
			var PresenceCondition disjunctionPC = null
			for (PresenceCondition pc : declarationPCs.reverseView) {
				disjunctionPC = if (disjunctionPC == null) pc else pc.or(disjunctionPC)
			}
			
			// If the variable PC does not imply the PC disjunction
			// then it doesn't imply any of the PCs.
			if (!varPC.getBDD.imp(disjunctionPC.getBDD).isOne) {
				println('''Reconfigurator error: «varName» undefined under «disjunctionPC.not».''')
				return null
			}
			
			// Initialize the expression to null.
			var GNode exp = null
			
			if (disjunctionPC.isFalse) {
				exp = node
			}
			
			for (PresenceCondition pc : declarationPCs.reverseView) {
				// For each PC create a new Identifier.
				val newExp = node.replaceTextWithVarName(varName + "_V" + pcidmap.get_id(pc))
				
				// wrap the new Identifier around the conditional expression.
				exp = if (exp == null) newExp else
				 GNode::create("PrimaryExpression",
					new Language<CTag>(CTag.LPAREN),
			 		GNode::create("ConditionalExpression",
			 			pc.getBDD.cexp,
			 			new Language<CTag>(CTag.QUESTION),
			 			newExp,
			 			new Language<CTag>(CTag.COLON),
			 			exp
			 			),
			 		new Language<CTag>(CTag.RPAREN)
				)
			}
			exp
		}
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
	
	private def computePCs (String varName, PresenceCondition varPC){
		val declarationPCs = new ArrayList<PresenceCondition>
		
		for (SimpleEntry<GNode,HashMap<String, List<PresenceCondition>>> scope : localVariableScopes.toList.reverseView) {
			val variables = scope.value
			
			if (variables.containsKey(varName)) {				// if the variable is declared in the current scope
				val scopePCs = variables.get(varName)
				if (scopePCs.exists[it.is(varPC)]) {				// if the current scope pcs contain the exact variable pc
					declarationPCs.add(varPC)						// add the one and return
					return declarationPCs
				} else {											// otherwise
					for (PresenceCondition pc : scopePCs) {
						if (varPC.BDD.imp(pc.BDD).isOne) {
							declarationPCs.add(pc)					// add the ones that are implied by the var PC
						}
					}
					
					// compute the disjunction of all declaration PCs up to this point
					var PresenceCondition disjunctionPC = Reconfigurator::presenceConditionManager.newPresenceCondition(false)
					for (PresenceCondition pc : declarationPCs) {
						disjunctionPC = if (disjunctionPC == null) pc else pc.or(disjunctionPC)
					}
					if (disjunctionPC.isTrue) {						// if the PCs collected so far cover the universe
						return declarationPCs							// return
					}
				}
			}													// otherwise move to the next scope
		}
		
		return declarationPCs
	}
	
	override dispatch Object transform(GNode node) {
		if (
			node.name.equals("PrimaryIdentifier")
			|| (node.name.equals("Increment")
				&& node.filter(GNode).head.name.equals("PrimaryIdentifier")
			)
		) {
			val varName =
				if (node.name.equals("PrimaryIdentifier"))
					(node.get(0) as Language<CTag>).toString
				else if (node.name.equals("Increment"))
					(node.filter(GNode).head.get(0) as Language<CTag>).toString
			
			val declarationPCs = computePCs(varName, externalGuard.and(node.presenceCondition))

			val exp = buildExp(node, varName, externalGuard.and(node.presenceCondition), declarationPCs)
			
			if(exp != null)
				return exp
			else
				return node
//		} else if(node.name.equals("AssignmentExpression")) {
//			println
//			println
//			println('''----------------------------''')
//			println('''- RewriteVariableUse''')
//			println('''----------------------------''')
//			println('''- «node»''')
		}
		node
	}
}
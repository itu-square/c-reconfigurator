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
import dk.itu.models.strategies.TopDownStrategy

class RewriteVariableUseRule extends AncestorGuaranteedRule {
	
	private val HashMap<PresenceCondition, String> pcidmap
	protected val ArrayList<SimpleEntry<GNode,HashMap<String, List<PresenceCondition>>>> localVariableScopes
	
	protected val PresenceCondition externalGuard
	
//	// In case we rename variables in a Declaration Assignment
//	// the currenttly declared variable does not refer to previous scopes.
//	// int a = a;   is equivalent to   int a;
//	//                                 a = a;
//	// Therefore it should only be replaced with its new name.
//	protected val String currentDeclarationOldName
//	protected val String currentDeclarationNewName
	
	new (
		ArrayList<SimpleEntry<GNode,HashMap<String, List<PresenceCondition>>>> localVariableScopes,
		PresenceCondition externalGuard,
		HashMap<PresenceCondition, String> pcidmap
	) {
		super()
		this.localVariableScopes = localVariableScopes
		this.externalGuard = externalGuard
		this.pcidmap = pcidmap
//		this.currentDeclarationOldName = ""
//		this.currentDeclarationNewName = ""
	}
	
//	new (
//		ArrayList<SimpleEntry<GNode,HashMap<String, List<PresenceCondition>>>> localVariableScopes,
//		PresenceCondition externalGuard,
//		HashMap<PresenceCondition, String> pcidmap,
//		String currentDeclarationOldName,
//		String currentDeclarationNewName
//	) {
//		super()
//		this.localVariableScopes = localVariableScopes
//		this.externalGuard = externalGuard
//		this.pcidmap = pcidmap
//		this.currentDeclarationOldName = currentDeclarationOldName
//		this.currentDeclarationNewName = currentDeclarationNewName
//	}
	
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
    	tdn.register(new ReplaceIdentifiersRule(varName))
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
			if (!varPC.BDD.imp(disjunctionPC.BDD).isOne) {
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
			 			pc.BDD.cexp,
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
			debugln('''| scope: «scope.value»''')
			debugln('''|             «scope.value.containsKey(varName)»''')
			if(scope.value.containsKey(varName)) {
				val scopePCs = scope.value.get(varName)
				declarationPCs.addAll(scopePCs)
				return declarationPCs
//				declarationPCs.addAll(scope.value.get(varName))
//				return declarationPCs
//			} else {
//				for (PresenceCondition pc in scope.g)
			}
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
			debugln
			debugln("------------------------")
			debugln("| RewriteVariableUseRule ")
			debugln("------------------------")
			debugln('''| «node.name» => «node.printCode»''')
			
			val varName =
				if (node.name.equals("PrimaryIdentifier"))
					(node.get(0) as Language<CTag>).toString
				else if (node.name.equals("Increment")) {
					var v1 = node.filter(GNode)
					var v2 = node.filter(GNode).head
					var v3 = node.filter(GNode).head.get(0)
					(node.filter(GNode).head.get(0) as Language<CTag>).toString
				}	
			
			debugln('''| variable name     => «varName»''')
			debugln('''| variable local pc => «node.presenceCondition»''')
			debugln('''| variable exrt grd => «externalGuard.PCtoCPPexp»''')
			debugln('''| loc var scopes    => «localVariableScopes.size»''')
			val declarationPCs = computePCs(varName, externalGuard.and(node.presenceCondition))
			debugln('''| declarationPCs ''')
			declarationPCs.forEach[
				debugln('''| - «PCtoCPPexp»''')
			]
			
			debugln("| Expression")
			val exp = buildExp(node, varName, externalGuard.and(node.presenceCondition), declarationPCs)
			debugln('''| «if (exp != null) exp else "NULL"»''')
			debugln('''| «if (exp != null) exp.printCode else "NULL"»''')
			
			if(exp != null)
				return exp
			else
				return node
//		} else if (node.name.equals("PrimaryIdentifier")
//			&& variableExists((node.get(0) as Language<CTag>).toString)
//		) {
//			var varname = (node.get(0) as Language<CTag>).toString
////			println
////			println('''::> «varname» («ancestors.head.printCode»)''')
////			println('''contains: «variableExists((node.get(0) as Language<CTag>).toString)»''')
////			println('''externalGuard: «externalGuard.PCtoCPPexp»''')
//			val newExp = buildExp((node.get(0) as Language<CTag>).toString)
//			if (newExp != null) {
////				println('''newExp: «newExp.printCode»''')
//				return newExp
//			}
//		} else if (node.name.equals("AssignmentExpression")) {
//			
		}
		node
	}
}
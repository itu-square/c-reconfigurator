package dk.itu.models.rules.phase3variables

import dk.itu.models.DeclarationPCMap
import dk.itu.models.PresenceConditionIdMap
import dk.itu.models.Reconfigurator
import dk.itu.models.rules.AncestorGuaranteedRule
import java.util.AbstractMap.SimpleEntry
import java.util.ArrayList
import java.util.HashMap
import java.util.List
import xtc.lang.cpp.CTag
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.tree.GNode
import xtc.util.Pair

import static extension dk.itu.models.Extensions.*
import xtc.tree.Node

class RewriteVariableUseRule extends AncestorGuaranteedRule {
	
	private val PresenceConditionIdMap pcidmap
	protected val ArrayList<SimpleEntry<GNode,DeclarationPCMap>> variableDeclarationScopes
	
	protected val PresenceCondition externalGuard
	
	new (
		ArrayList<SimpleEntry<GNode,DeclarationPCMap>> variableDeclarationScopes,
		PresenceCondition externalGuard,
		PresenceConditionIdMap pcidmap
	) {
		super()
		this.variableDeclarationScopes = variableDeclarationScopes
		this.externalGuard = externalGuard
		this.pcidmap = pcidmap
	}
	
	static def String get_id (HashMap<PresenceCondition, String> map, PresenceCondition pc) {
		map.get(map.keySet.findFirst[is(pc)])
	}
    
    private def setHandled(Node node) {
    	node.setProperty("HandledByRewriteVariableUseRule", true)
    }
    
	protected def buildExp(GNode node, String varName, PresenceCondition guard, List<PresenceCondition> declarationPCs) {
		
		if (declarationPCs.empty) { // there are no declarations of this variable
			if (node.name.equals("PrimaryIdentifier"))
				node.setHandled
			else
				node.getDescendantNode("PrimaryIdentifier").setHandled
			return node
		} else {
			
			// compute the disjunction of all declaration PCs
			var PresenceCondition disjunctionPC = null
			for (PresenceCondition pc : declarationPCs.reverseView) {
				disjunctionPC = if (disjunctionPC == null) pc else pc.or(disjunctionPC)
			}
			
			// If the guard and the PC disjunction cannot be true in the same time
			// then the guard cannot be true in the same time with any of the PCs.
			if (guard.and(disjunctionPC).isFalse) {
				println('''Reconfigurator error: «varName» undefined under «guard».''')
				if (node.name.equals("PrimaryIdentifier"))
				node.setHandled
			else
				node.getDescendantNode("PrimaryIdentifier").setHandled
				return node
 			}
			
			// Initialize the expression to null.
			var GNode exp = null
			
			if (!guard.getBDD.imp(disjunctionPC.getBDD).isOne) {
				if (node.name.equals("PrimaryIdentifier"))
				node.setHandled
			else
				node.getDescendantNode("PrimaryIdentifier").setHandled
				exp = node
			}
			
			for (PresenceCondition pc : declarationPCs.reverseView) {
				// For each PC create a new Identifier.
				val newExp = node.replaceIdentifierVarName(varName, varName + "_V" + pcidmap.getId(pc))
				
				// wrap the new Identifier around the conditional expression.
				exp = if (exp == null) newExp else
				 GNode::create("PrimaryExpression",
					new Language<CTag>(CTag.LPAREN),
			 		GNode::create("ConditionalExpression",
			 			pc.PCtoCexp,
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
		
		for (SimpleEntry<GNode,DeclarationPCMap> scope : variableDeclarationScopes.toList.reverseView) {
			val variables = scope.value
			
			if (variables.containsDeclaration(varName)) {				// if the variable is declared in the current scope
				val scopePCs = variables.pcList(varName)
				if (scopePCs.exists[it.is(varPC)]) {				// if the current scope pcs contain the exact variable pc
					declarationPCs.add(varPC)						// add the one and return
					return declarationPCs
				} else {											// otherwise
				
					// AFLA: this filter doesn't seem to be working
					// neither this way or reversed
					// just add all instead
					for (PresenceCondition pc : scopePCs) {
						if (!varPC.and(pc).isFalse) {
							declarationPCs.add(pc)					// add the ones that are not falsified by the var PC
						}
					}
//					declarationPCs.addAll(scopePCs)
					
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
		
		if(
			(
				node.name.equals("PrimaryIdentifier")
				&& !node.getBooleanProperty("HandledByRewriteVariableUseRule")
			) || (
				#["Increment", "Subscript", "AssignmentExpression", "UnaryExpression"].contains(node.name)
				&& node.getDescendantNode("PrimaryIdentifier") != null
				&& !node.getDescendantNode("PrimaryIdentifier").getBooleanProperty("HandledByRewriteVariableUseRule")
			)
		){
				var newNode = node
				
				var String varName
				
				if (node.name.equals("PrimaryIdentifier"))
					varName =(node.get(0) as Language<CTag>).toString
				else if (#["Increment", "Subscript", "AssignmentExpression", "UnaryExpression"].contains(node.name)) {
					varName = node.getDescendantNode("PrimaryIdentifier").get(0).toString
					newNode = GNode::create("PrimaryExpression",
							new Language<CTag>(CTag::LPAREN),
							node,
							new Language<CTag>(CTag::RPAREN))
				} else
					throw new Exception("RewriteVariableUseRule: unknown location of variable name")
				
				val declarationPCs = computePCs(varName, externalGuard.and(node.presenceCondition))
				val exp = buildExp(newNode, varName, externalGuard.and(node.presenceCondition), declarationPCs)
				
				if(exp != null)
					return exp
				else
					return node
		}
		node
	}
}
package dk.itu.models.rules.phase3variables

import dk.itu.models.PresenceConditionIdMap
import dk.itu.models.Reconfigurator
import dk.itu.models.rules.AncestorGuaranteedRule
import dk.itu.models.utils.Declaration
import dk.itu.models.utils.DeclarationPCMap
import dk.itu.models.utils.VariableDeclaration
import java.util.AbstractMap.SimpleEntry
import java.util.ArrayList
import java.util.HashMap
import java.util.List
import xtc.lang.cpp.CTag
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.tree.GNode
import xtc.tree.Node
import xtc.util.Pair

import static extension dk.itu.models.Extensions.*

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
    
	protected def buildExp(
		String varName,
		GNode node,
		List<SimpleEntry<Declaration, PresenceCondition>> declarations) {
		
		if (
			declarations.empty
			|| (declarations.size == 1 && declarations.get(0).value.isTrue)
		) {
			if (node.name.equals("PrimaryIdentifier"))
				node.setHandled
			else
				node.getDescendantNode("PrimaryIdentifier").setHandled
			return node
		} else {
			var GNode exp = null
			for (SimpleEntry<Declaration, PresenceCondition> pair : declarations.reverseView) {
				val newVarName = pair.key.name
				val pc = pair.value
				
				val newExp = if(newVarName.equals(varName)) node else node.replaceIdentifierVarName(varName, newVarName)
				if (newExp.name.equals("PrimaryIdentifier"))
					newExp.setHandled
				else
					newExp.getDescendantNode("PrimaryIdentifier").setHandled
				
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
			return exp
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
	
	private def filterDeclarations (String varName, PresenceCondition varPC){
		val declarations = new ArrayList<SimpleEntry<Declaration,PresenceCondition>>
		var disjunctionPC = Reconfigurator::presenceConditionManager.newPresenceCondition(false)
		
		for (SimpleEntry<GNode,DeclarationPCMap> scope : variableDeclarationScopes.toList.reverseView) {
			val variableDeclarationPCMap = scope.value
			
			if (variableDeclarationPCMap.containsDeclaration(varName)) {				// if the variable is declared in the current scope
				
				var exactDeclaration = variableDeclarationPCMap.declarationList(varName).findFirst[it.value.is(varPC)]
				if (exactDeclaration != null) {											// if the current scope pcs contain the exact variable pc
					declarations.add(exactDeclaration)									// add the one and return
					return declarations
				}
				
				for (SimpleEntry<Declaration, PresenceCondition> pair : variableDeclarationPCMap.declarationList(varName)) {
					val pc = pair.value
					if (!varPC.and(pc).isFalse) {
						declarations.add(pair)											// add the ones that are not falsified by the var PC
						disjunctionPC = pc.or(disjunctionPC)
					}
				}
					
				if (disjunctionPC.isTrue) {												// if the PCs collected so far cover the universe
					return declarations													// return
				}
			}																			// otherwise move to the next scope
		}
					
		if (!disjunctionPC.isTrue) {												// if the PCs collected so far cover the universe
			declarations.add(new SimpleEntry<Declaration, PresenceCondition>(
				new VariableDeclaration(varName, null),
				disjunctionPC.not
			))
		}
		
		return declarations
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
			
			if (node.name.equals("PrimaryIdentifier")) {
				varName =(node.get(0) as Language<CTag>).toString
			} else if (
				#["Increment", "Subscript", "AssignmentExpression", "UnaryExpression"]
					.contains(node.name)
			) {
				varName = node.getDescendantNode("PrimaryIdentifier").get(0).toString
				newNode = GNode::create("PrimaryExpression",
						new Language<CTag>(CTag::LPAREN),
						node,
						new Language<CTag>(CTag::RPAREN))
			} else {
				throw new Exception("RewriteVariableUseRule: unknown location of variable name")
			}
			
			val declarations = filterDeclarations(varName, externalGuard.and(node.presenceCondition))
			
			val exp = buildExp(varName, node, declarations)
			
			if(exp != null) {
				return exp
			} else {
				return node
			}
		}
		node
	}
}
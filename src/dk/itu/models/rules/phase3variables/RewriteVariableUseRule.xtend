package dk.itu.models.rules.phase3variables

import dk.itu.models.Reconfigurator
import dk.itu.models.rules.AncestorGuaranteedRule
import dk.itu.models.utils.DeclarationPCPair
import dk.itu.models.utils.DeclarationScopeStack
import dk.itu.models.utils.VariableDeclaration
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
	
	protected val DeclarationScopeStack variableDeclarationScopes
	
	protected val PresenceCondition externalGuard
	
	new (
		DeclarationScopeStack variableDeclarationScopes,
		PresenceCondition externalGuard
	) {
		super()
		this.variableDeclarationScopes = variableDeclarationScopes
		this.externalGuard = externalGuard
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
		List<DeclarationPCPair> declarations,
		PresenceCondition varPC
	) {
		if (
			declarations.empty
			|| (declarations.size == 1 && declarations.get(0).pc.isTrue)
		) {
			if (node.name.equals("PrimaryIdentifier"))
				node.setHandled
			else
				node.getDescendantNode("PrimaryIdentifier").setHandled
			return node
		} else {
			var GNode exp = null
			for (DeclarationPCPair pair : declarations.reverseView) {
				val newVarName = pair.declaration.name
				var pc = pair.pc.restrict(varPC.not)
				if (pc.isFalse) pc = pair.pc.simplify(varPC)
				// if the simplification reduced the PC completely to 1/True
				// then we can use the original PC (pair.value)
				if (pc.isTrue) pc = pair.pc
				
				val newExp = if(newVarName.equals(varName)) node else node.replaceIdentifierVarName(varName, newVarName)
				if (newExp.name.equals("PrimaryIdentifier"))
					newExp.setHandled
				else
					newExp.getDescendantNode("PrimaryIdentifier").setHandled
				
				exp = if (exp === null) {
					newExp
				} else {
					val exp1 = if (newExp.name.equals("AssignmentExpression")) {
						GNode::create("PrimaryExpression",
							new Language<CTag>(CTag.LPAREN),
							newExp,
							new Language<CTag>(CTag.RPAREN)
						)
					} else { newExp }
					
					val exp2 = if (exp.name.equals("AssignmentExpression")) {
						GNode::create("PrimaryExpression",
							new Language<CTag>(CTag.LPAREN),
							exp,
							new Language<CTag>(CTag.RPAREN)
						)
					} else { exp }
					
					GNode::create("PrimaryExpression",
						new Language<CTag>(CTag.LPAREN),
				 		GNode::create("ConditionalExpression",
				 			pc.PCtoCexp,
				 			new Language<CTag>(CTag.QUESTION),
				 			exp1,
				 			new Language<CTag>(CTag.COLON),
				 			exp2
				 			),
				 		new Language<CTag>(CTag.RPAREN)
						)
				}
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
	
	private def filterDeclarations (DeclarationScopeStack inDeclarations, String varName, PresenceCondition guardPC) {
		
		val declarations = new ArrayList<DeclarationPCPair>
		
		var disjunctionPC = Reconfigurator::presenceConditionManager.newPresenceCondition(false)
		for (DeclarationPCPair pair : inDeclarations.declarationList(varName).reverseView) {
			val pc = pair.pc
			if (!guardPC.and(pc).isFalse) {
				declarations.add(pair)
				disjunctionPC = pc.or(disjunctionPC)
			}
		}
		
		if (!guardPC.BDD.imp(disjunctionPC.BDD).isOne) {
			declarations.add(new DeclarationPCPair(
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
				&& node.getDescendantNode("PrimaryIdentifier") !== null
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
			
			if (variableDeclarationScopes.getDeclaration(varName) !== null) {
				val varPC = externalGuard.and(node.presenceCondition)
				
				val declarations = filterDeclarations(variableDeclarationScopes, varName, varPC)
				val exp = buildExp(varName, node, declarations, varPC)
				
				if(exp !== null) {
					return exp
				}
			}
		}
		node
	}
}
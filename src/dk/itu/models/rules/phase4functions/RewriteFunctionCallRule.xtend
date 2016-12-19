package dk.itu.models.rules.phase4functions

import dk.itu.models.PresenceConditionIdMap
import dk.itu.models.Reconfigurator
import dk.itu.models.rules.AncestorGuaranteedRule
import dk.itu.models.utils.Declaration
import dk.itu.models.utils.DeclarationPCMap
import dk.itu.models.utils.FunctionDeclaration
import java.util.AbstractMap.SimpleEntry
import java.util.ArrayList
import java.util.HashMap
import java.util.List
import xtc.lang.cpp.CTag
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.lang.cpp.Syntax.Text
import xtc.tree.GNode
import xtc.util.Pair

import static extension dk.itu.models.Extensions.*

class RewriteFunctionCallRule extends AncestorGuaranteedRule {

	private val DeclarationPCMap functionDeclarations
	private val PresenceConditionIdMap pcidmap
	static def String get_id (HashMap<PresenceCondition, String> map, PresenceCondition pc) {
		map.get(map.keySet.findFirst[is(pc)])
	}
	
	
	protected val PresenceCondition externalGuard
	
	new (DeclarationPCMap functionDeclarations, PresenceCondition externalGuard, PresenceConditionIdMap pcidmap) {
		this.functionDeclarations = functionDeclarations
		this.pcidmap = pcidmap
		this.externalGuard = externalGuard
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
	
	def buildExp (
		GNode node,
		List<SimpleEntry<Declaration, PresenceCondition>> declarations,
		Pair<?> args,
		PresenceCondition varPC
	) {
		if (
			declarations.empty
			|| (declarations.size == 1 && declarations.get(0).value.isTrue)
		) {
			node.setProperty("HandledByRewriteFunctionCallRule", true)
			return node
		} else {
			var GNode exp = null
			for (SimpleEntry<Declaration, PresenceCondition> pair : declarations.reverseView) {
				val funcName = pair.key.name
				var pc = pair.value.restrict(varPC.not)
				if (pc.isFalse) pc = pair.value.simplify(varPC)
				
				val newCall = GNode::create(
					"FunctionCall",
			 		GNode::create("PrimaryIdentifier", new Text(CTag.IDENTIFIER, funcName)),
			 		GNode::createFromPair("ExpressionList", args))
			 	newCall.setProperty("HandledByRewriteFunctionCallRule", true)
				
				exp = if (exp == null) newCall else
				 GNode::create("PrimaryExpression",
					new Language<CTag>(CTag.LPAREN),
			 		GNode::create("ConditionalExpression",
			 			pc.PCtoCexp,
			 			new Language<CTag>(CTag.QUESTION),
			 			newCall,
			 			new Language<CTag>(CTag.COLON),
			 			exp),
			 		new Language<CTag>(CTag.RPAREN))
			}
			return exp
		}
	}
	
	private def filterDeclarations(String funcName, PresenceCondition callPC) {
		
		val declarations = new ArrayList<SimpleEntry<Declaration,PresenceCondition>>
		
		if (!functionDeclarations.containsDeclaration(funcName)) {
			return declarations
		}
		
		var exactDeclaration = functionDeclarations.declarationList(funcName).findFirst[it.value.is(callPC)]
		if (exactDeclaration != null) {
			declarations.add(exactDeclaration)
			return declarations
		}
		
		var disjunctionPC = Reconfigurator::presenceConditionManager.newPresenceCondition(false)
		for (SimpleEntry<Declaration, PresenceCondition> pair : functionDeclarations.declarationList(funcName)) {
			val pc = pair.value
			if (!callPC.and(pc).isFalse) {
				declarations.add(pair)
				disjunctionPC = pc.or(disjunctionPC)
			}
		}
		
		if (!callPC.BDD.imp(disjunctionPC.BDD).isOne) {
			declarations.add(new SimpleEntry<Declaration, PresenceCondition>(
				new FunctionDeclaration(funcName, null),
				disjunctionPC.not
			))
		}
		
		return declarations
	}
	
	override dispatch Object transform(GNode node) {
		if (node.name.equals("FunctionCall")
			&& functionDeclarations.containsDeclaration((node.get(0) as GNode).get(0).toString)
			&& !node.getBooleanProperty("HandledByRewriteFunctionCallRule")
		) {
			debug("RewriteFunctionCallRule", true)
			val fcall = (node.get(0) as GNode).get(0).toString
			
			val varPC = externalGuard.and(node.presenceCondition)
			
			val declarations = filterDeclarations(fcall, varPC)
			val exp = buildExp(node, declarations, node.toPair.tail, varPC)
			
			if(exp != null) {
				return exp
			} else {
				return node
			}
		}
		node
	}

}
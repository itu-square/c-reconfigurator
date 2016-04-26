package dk.itu.models.rules.phase4functions

import dk.itu.models.Reconfigurator
import dk.itu.models.rules.AncestorGuaranteedRule
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

	private val HashMap<PresenceCondition, String> pcidmap
	static def String get_id (HashMap<PresenceCondition, String> map, PresenceCondition pc) {
		map.get(map.keySet.findFirst[is(pc)])
	}
	
	private val HashMap<String, List<PresenceCondition>> fmap
	
	protected val PresenceCondition externalGuard
	
	new (HashMap<String, List<PresenceCondition>> fmap, PresenceCondition externalGuard,
		HashMap<PresenceCondition, String> pcidmap) {
		this.fmap = fmap
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
	
	def buildExp (GNode node, String fname, List<PresenceCondition> declarationPCs, Pair<?> args, PresenceCondition guard) {
		
		if (declarationPCs.empty) { // there are no declarations of this variable
			return null
		} else {
			var PresenceCondition disjunctionPC = null
			for (PresenceCondition pc : declarationPCs.reverseView) {
				disjunctionPC = if (disjunctionPC == null) pc else pc.or(disjunctionPC)
			}
			
			if (!guard.getBDD.imp(disjunctionPC.getBDD).isOne) {
				println('''Reconfigurator error: «fname» undefined under «disjunctionPC.not».''')
				return null
			}
			
			var GNode exp = null
			
			if (disjunctionPC.isFalse) {
				exp = node
			}
			
			for (PresenceCondition pc : declarationPCs.reverseView) {
				val newCall = GNode::create("FunctionCall",
			 				GNode::create("PrimaryIdentifier", new Text(CTag.IDENTIFIER, fname + "_V" + pcidmap.get_id(pc))),
			 				GNode::createFromPair("ExpressionList", args));
				
				exp = if (exp == null) newCall else
				 GNode::create("PrimaryExpression",
					new Language<CTag>(CTag.LPAREN),
			 		GNode::create("ConditionalExpression",
			 			pc.PCtoCexp,
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
	}
	
	private def computePCs (String funcName, PresenceCondition callPC){
		val declarationPCs = new ArrayList<PresenceCondition>
		
			if (fmap.containsKey(funcName)) {				// if the variable is declared in the current scope
				val scopePCs = fmap.get(funcName)
				if (scopePCs.exists[it.is(callPC)]) {				// if the current scope pcs contain the exact variable pc
					declarationPCs.add(callPC)						// add the one and return
					return declarationPCs
				} else {											// otherwise
					
					// AFLA: this filter doesn't seem to be working
					// neither this way or reversed
					// just add all instead
					for (PresenceCondition pc : scopePCs) {
						if (!callPC.and(pc).isFalse) {
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
		
		
		return declarationPCs
	}
	
	override dispatch Object transform(GNode node) {
		if (node.name.equals("FunctionCall")
			&& fmap.containsKey((node.get(0) as GNode).get(0).toString)
		) {
			val fcall = (node.get(0) as GNode).get(0).toString
			
			val declarationPCs = computePCs(fcall, externalGuard.and(node.presenceCondition))
			val exp = buildExp(node, fcall, declarationPCs, node.toPair.tail, externalGuard.and(node.presenceCondition))

			if(exp != null)
				return exp
			else
				return node
		}
		node
	}

}
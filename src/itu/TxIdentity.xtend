package itu

import xtc.lang.cpp.PresenceConditionManager
import java.util.List
import xtc.tree.Node
import xtc.lang.cpp.Syntax.Language
import xtc.lang.cpp.CTag
import xtc.tree.GNode

class TxIdentity implements Tx {
	
	val manager = new PresenceConditionManager
	
	override tx_start(PresenceConditionManager.PresenceCondition condition, List<Node> ancestors) {
		manager.newPresenceCondition(condition.BDD)
	}
	
	override tx_end(PresenceConditionManager.PresenceCondition condition, List<Node> ancestors) {
	
	}
	
	override tx_start(Language<CTag> language, List<Node> ancestors) {
		language.copy
	}
	
	override tx_end(Language<CTag> language, List<Node> ancestors) {
		
	}
	
	override tx_start(GNode node, List<Node> ancestors) {
		GNode::create(node.name)
	}
	
	override tx_end(GNode node, List<Node> ancestors) {
		
	}
	
	override tx_start(Node node, List<Node> ancestors) {
		GNode::create(node.name)
	}
	
	override tx_end(Node node, List<Node> ancestors) {
		
	}
	
}
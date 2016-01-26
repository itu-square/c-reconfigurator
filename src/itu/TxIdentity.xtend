package itu

import xtc.lang.cpp.PresenceConditionManager
import java.util.List
import xtc.tree.Node
import xtc.lang.cpp.Syntax.Language
import xtc.lang.cpp.CTag
import xtc.tree.GNode

class TxIdentity extends Tx {
	
	new(PresenceConditionManager manager) {
		super(manager)
	}
	
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
		val newNode = GNode::create(node.name)
		node.forEach[newNode.add(it)]
		newNode
	}
	
	override tx_end(GNode node, List<Node> ancestors) {
		
	}
	
	override tx_start(Node node, List<Node> ancestors) {
		val newNode = GNode::create(node.name)
		node.forEach[newNode.add(it)]
		newNode
	}
	
	override tx_end(Node node, List<Node> ancestors) {
		
	}
	
}
package itu

import xtc.tree.GNode
import xtc.tree.Node
import xtc.lang.cpp.PresenceConditionManager
import xtc.lang.cpp.Syntax.Language
import java.util.List

class TxIfdef2If implements Tx {
	
	val manager = new PresenceConditionManager
	
	override tx_start(PresenceConditionManager.PresenceCondition condition, List<Node> ancestors) {
		val idx = ancestors.last.indexOf(condition)
		println(condition)
		
		ancestors.last.remove(idx)
		ancestors.last.add(idx, manager.newPresenceCondition(false))
	}
	
	override tx_end(PresenceConditionManager.PresenceCondition condition, List<Node> ancestors) {
		
	}
	
	override tx_start(Language language, List<Node> ancestors) {
		
	}
	
	override tx_end(Language language, List<Node> ancestors) {
		
	}
	
	override tx_start(GNode node, List<Node> ancestors) {
		
	}
	
	override tx_end(GNode node, List<Node> ancestors) {
		
	}
	
	override tx_start(Node node, List<Node> ancestors) {
		
	}
	
	override tx_end(Node node, List<Node> ancestors) {
		
	}

}

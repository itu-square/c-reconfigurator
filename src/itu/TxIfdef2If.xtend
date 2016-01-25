package itu

import xtc.tree.GNode
import xtc.tree.Node
import xtc.lang.cpp.PresenceConditionManager
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import java.util.List
import xtc.lang.cpp.CTag

class TxIfdef2If implements Tx {
	
	val manager = new PresenceConditionManager
	
	override PresenceCondition tx_start(PresenceCondition condition, List<Node> ancestors) {
//		val idx = ancestors.last.indexOf(condition)
//		println(condition)
//		
//		ancestors.last.remove(idx)
//		ancestors.last.add(idx, manager.newPresenceCondition(false))
		condition
	}
	
	override void tx_end(PresenceCondition condition, List<Node> ancestors) {
		
	}
	
	override Language<CTag> tx_start(Language<CTag> language, List<Node> ancestors) {
		language
	}
	
	override void tx_end(Language<CTag> language, List<Node> ancestors) {
		
	}
	
	override GNode tx_start(GNode node, List<Node> ancestors) {
		node
	}
	
	override void tx_end(GNode node, List<Node> ancestors) {
		
	}
	
	override Node tx_start(Node node, List<Node> ancestors) {
		node
	}
	
	override void tx_end(Node node, List<Node> ancestors) {
		
	}

}

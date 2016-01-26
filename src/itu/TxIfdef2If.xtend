package itu

import xtc.tree.GNode
import xtc.tree.Node
import xtc.lang.cpp.PresenceConditionManager
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import java.util.List
import xtc.lang.cpp.CTag
import xtc.lang.cpp.Syntax.Text

class TxIfdef2If extends Tx {
	
	new(PresenceConditionManager manager) {
		super(manager)
	}
	
	override PresenceCondition tx_start(PresenceCondition condition, List<Node> ancestors) {
//		println('''«condition» («»)''')
//		condition
		manager.newPresenceCondition(condition.BDD)
	}
	
	override void tx_end(PresenceCondition condition, List<Node> ancestors) {
		
	}
	
	override Language<CTag> tx_start(Language<CTag> language, List<Node> ancestors) {
		language.copy
	}
	
	override void tx_end(Language<CTag> language, List<Node> ancestors) {
		
	}
	
	override GNode tx_start(GNode node, List<Node> ancestors) {
		if(node.name == "Conditional"
			&& node.size == 4
			&& (node.get(0) as PresenceCondition).not.toString == (node.get(2) as PresenceCondition).toString
			&& (node.get(0) as PresenceCondition).toString.startsWith("(defined")){
//				println(node)
//				println(manager.variableManager.getName(0))
//				println(manager.variableManager.getName(1))
//				println(manager.variableManager.getName(2))
//				
//				for (Object o : (node.get(0) as PresenceCondition).BDD.allsat)
//					for (var i = 0; i < (o as byte[]).length; i++){
//						print('''---> «i»    «(o as byte[]).get(i)»                ''')
//						switch((o as byte[]).get(i)) {
//            				case 0: println("!")
//            				case 1: println(manager.variableManager.getName(i))
//            	        }}
				var v = (node.get(0) as PresenceCondition).toString
				
				val n = GNode::create("SelectionStatement")
				
					n.add(new Language<CTag>(CTag.^IF))
					n.add(new Language<CTag>(CTag.LPAREN))
					n.add(GNode.create("PrimaryIdentifier", new Text<CTag>(CTag.OCTALconstant, v.substring(v.indexOf(' ')+1, v.indexOf(')')))))
					n.add(new Language<CTag>(CTag.RPAREN))
					n.add(node.get(1))
					n.add(new Language<CTag>(CTag.^ELSE))
					n.add(node.get(3))
				
				n
			}
			else {
				val newNode = GNode::create(node.name)
				node.forEach[newNode.add(it)]
				newNode
			}
	}
	
	override void tx_end(GNode node, List<Node> ancestors) {
		
	}
	
	override Node tx_start(Node node, List<Node> ancestors) {
		val newNode = GNode::create(node.name)
		node.forEach[newNode.add(it)]
		newNode
	}
	
	override void tx_end(Node node, List<Node> ancestors) {
		
	}

}

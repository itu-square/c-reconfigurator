package dk.itu.models

import xtc.tree.GNode
import xtc.tree.Node
import xtc.lang.cpp.PresenceConditionManager
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import java.util.List
import xtc.lang.cpp.CTag
import xtc.lang.cpp.Syntax.Text
import java.util.ArrayList
import java.util.Collection

class TxIfdef2If  {
	
	// the PresenceConditionManager which was used when building the AST
	// without this it is not possible to access the variable names in the PresenceConditions
	protected val PresenceConditionManager manager
	
	// a list of all ancestors of the current node
	// various uses (e.g. indentation)
	protected val ArrayList<Node> ancestors
	
	new(PresenceConditionManager manager) {
		this.manager = manager
    	this.ancestors = new ArrayList<Node>
	}
	
	def transform(Object o) {
		ancestors.clear
		t(o)
	}
	
	def private dispatch PresenceCondition t(PresenceCondition condition) {
		manager.newPresenceCondition(condition.getBDD)
	}

	def private dispatch Language<CTag> t(Language<CTag> language) {
		language.copy
	}
	
	def private dispatch GNode t(GNode node) {
//		if(node.name == "Conditional"){
//			println(node)
//			node.forEach[println("  " + it)]
//			println
//			
//		}
		
		
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


				
				var defined = (node.get(0) as PresenceCondition).toString
				var variable = defined.substring(defined.indexOf(' ')+1, defined.indexOf(')'))
				
				ancestors.add(node)
				
				val newNode = GNode::create("SelectionStatement")
				newNode.addAll(#[
					new Language<CTag>(CTag.^IF),
					new Language<CTag>(CTag.LPAREN),
					GNode.create("PrimaryIdentifier", new Text<CTag>(CTag.OCTALconstant, variable)),
					new Language<CTag>(CTag.RPAREN),
					t(node.get(1)),
					new Language<CTag>(CTag.^ELSE),
					t(node.get(3))
				] as Collection<Object>)
				
				ancestors.remove(node)
				
				newNode
			}
			else {
				ancestors.add(node)
		
				val newNode = GNode::create(node.name)
				node.forEach[newNode.add(t(it))]
				
				ancestors.remove(node)
				
				newNode
			}
	}


}

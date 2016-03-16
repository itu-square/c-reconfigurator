package dk.itu.models.rules

import java.util.ArrayList
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.CTag
import xtc.lang.cpp.Syntax.Language
import xtc.tree.GNode
import xtc.util.Pair
import java.util.AbstractMap.SimpleEntry

abstract class ScopingRule extends AncestorGuaranteedRule {
	
	protected val ArrayList<SimpleEntry<GNode,ArrayList<String>>> localVariables
	
	new () {
		super()
		this.localVariables = new ArrayList<SimpleEntry<GNode,ArrayList<String>>>
	}
	
	protected def addScope(GNode node) {
		this.localVariables.add(new SimpleEntry<GNode,ArrayList<String>>(node, new ArrayList<String>))
	}
	
	protected def clearScope() {
		while (
			localVariables.size > 0 &&
			!ancestors.contains(localVariables.last.key)
		) {
			localVariables.remove(localVariables.size - 1)
		}
	}
	
	protected def addVariable(String name) {
		localVariables.last.value.add(name)
	}
	
	protected def variableExists(String name) {
		localVariables.map[value].flatten.exists[equals(name)]
	}
	
	def PresenceCondition transform(PresenceCondition cond) {
		println("sr")
		clearScope
		cond
	}

	def Language<CTag> transform(Language<CTag> lang) {
		println("sr")
		clearScope
		lang
	}

	def Pair<Object> transform(Pair<Object> pair) {
		println("sr")
		clearScope
		pair
	}
	
	def Object transform(GNode node) {
		clearScope
		if (node.name.equals("FunctionDefinition")) {
			addScope(node)
		}
		
		if (
			node.name.equals("SimpleDeclarator") &&
			ancestors.exists[name.equals("ParameterDeclaration")]
		) {
			val variableName = node.get(0).toString
			addVariable(variableName)
		}
		
		if (
			node.name.equals("Declaration") &&
			ancestors.exists[name.equals("FunctionDefinition")]
		) {
			val declaringList = node.get(0) as GNode
			val simpleDeclarator = declaringList.filter(GNode).findFirst[name.equals("SimpleDeclarator")]
			val variableName = simpleDeclarator.get(0).toString
			addVariable(variableName)
		}
		
		println("sr")
		node
	}
	
}
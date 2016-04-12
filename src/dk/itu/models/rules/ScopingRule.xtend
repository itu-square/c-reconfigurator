package dk.itu.models.rules

import java.util.AbstractMap.SimpleEntry
import java.util.ArrayList
import java.util.HashMap
import java.util.List
import xtc.lang.cpp.CTag
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.tree.GNode
import xtc.util.Pair

abstract class ScopingRule extends AncestorGuaranteedRule {
	
	protected val ArrayList<SimpleEntry<GNode,HashMap<String, List<PresenceCondition>>>> localVariableScopes
	
	new () {
		super()
		this.localVariableScopes = new ArrayList<SimpleEntry<GNode,HashMap<String, List<PresenceCondition>>>>
	}
	
	protected def addScope(GNode node) {
		this.localVariableScopes.add(new SimpleEntry<GNode,HashMap<String, List<PresenceCondition>>>(node, new HashMap<String, List<PresenceCondition>>))
	}
	
	protected def clearScope() {
		while (
			localVariableScopes.size > 0 &&
			!ancestors.contains(localVariableScopes.last.key)
		) {
			localVariableScopes.remove(localVariableScopes.size - 1)
		}
	}
	
	protected def addVariable(String name) {
		localVariableScopes.last.value.putIfAbsent(name, new ArrayList<PresenceCondition>)
	}
	
	protected def variableExists(String name) {
		localVariableScopes.exists[ se |
			se.value.keySet.contains(name)
		]
	}
	
	protected def List<PresenceCondition> getPCListForLastDeclaration(String name) {
		val scope = localVariableScopes.findLast[scope | scope.value.containsKey(name)]
		if (scope != null)
			scope.value.get(name)
		else
			null
	}
	
	def PresenceCondition transform(PresenceCondition cond) {
		clearScope
		cond
	}

	def Language<CTag> transform(Language<CTag> lang) {
		clearScope
		lang
	}

	def Pair<Object> transform(Pair<Object> pair) {
		clearScope
		pair
	}
	
	def Object transform(GNode node) {
		clearScope
		if (#["TranslationUnit", "FunctionDefinition"].contains(node.name)) {
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
			(node.get(0) as GNode).name.equals("DeclaringList")
		) {
			val declaringList = node.get(0) as GNode
			val simpleDeclarator =
				if ((declaringList.get(1) as GNode).name.equals("SimpleDeclarator"))
					(declaringList.get(1) as GNode)
				else if (((declaringList.get(1) as GNode).get(1) as GNode).name.equals("SimpleDeclarator"))
					((declaringList.get(1) as GNode).get(1) as GNode)
				else
					null
			
			if (simpleDeclarator != null) {
				val variableName = simpleDeclarator.get(0).toString
				addVariable(variableName.toString)
			}
		}
		
		node
	}
	
}
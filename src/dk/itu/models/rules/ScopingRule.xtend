package dk.itu.models.rules

import java.util.ArrayList
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.CTag
import xtc.lang.cpp.Syntax.Language
import xtc.tree.GNode
import xtc.util.Pair
import java.util.AbstractMap.SimpleEntry
import java.util.HashMap
import java.util.List
import xtc.lang.cpp.Syntax.Text

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
//		println("srcond")
		clearScope
		cond
	}

	def Language<CTag> transform(Language<CTag> lang) {
//		println("srlang")
		clearScope
		lang
	}

	def Pair<Object> transform(Pair<Object> pair) {
//		println("srpair")
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
			node.name.equals("Declaration")// &&
//			ancestors.exists[name.equals("FunctionDefinition")]
		) {
			val declaringList = node.get(0) as GNode
			val simpleDeclarator = declaringList.filter(GNode).findFirst[name.equals("SimpleDeclarator")]
			val variableName = simpleDeclarator.get(0) as Language<CTag>
//			println('''===> «variableName» («variableName.hasProperty("reconfiguratorVariable")»)''')
			if (!variableName.hasProperty("reconfiguratorVariable") ||
				!variableName.getBooleanProperty("reconfiguratorVariable")
			) {
				addVariable(variableName.toString)
			}
		}
		
//		println("srnode")
		node
	}
	
}
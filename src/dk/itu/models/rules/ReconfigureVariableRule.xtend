package dk.itu.models.rules

import dk.itu.models.strategies.TopDownStrategy
import java.util.HashMap
import xtc.lang.cpp.CTag
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.tree.GNode
import xtc.util.Pair

import static extension dk.itu.models.Extensions.*

class ReconfigureVariableRule extends ScopingRule {
	
	val public pcidmap = new HashMap<PresenceCondition, String>
	
	static def void put_pcid (HashMap<PresenceCondition, String> map, PresenceCondition pc, String id) {
		if (map.keySet.findFirst[is(pc)] == null)
			map.put(pc, id)
	}
	
	static def String get_id (HashMap<PresenceCondition, String> map, PresenceCondition pc) {
		map.get(map.keySet.findFirst[is(pc)])
	}

//	val public variableToPCMap = new HashMap<String, List<PresenceCondition>>
	
	override dispatch PresenceCondition transform(PresenceCondition cond) {
		cond
	}

	override dispatch Language<CTag> transform(Language<CTag> lang) {
		lang
	}

	override dispatch Pair<Object> transform(Pair<Object> pair) {
		pair
	}
	
	def debug(GNode node) {
			println
			println('''---- «node.name» ----------------------------------------------------''')
			print(node.printCode)
			println("-----------")
			localVariableScopes.forEach[ scope |
				println(''':> «scope.key.name»:''')
				scope.value.forEach[ variable, pcs |
					println('''   «variable»(«pcs.size»): ''')
					pcs.forEach[pc | println('''      «pc»''')] ] ]
			println
	}

	override dispatch Object transform(GNode node) {
		
		// Update the variable scopes and declarations.
		(this as ScopingRule).transform(node)
		
		// Visit a variable Declaration under a Conditional.
		if	(  node.name.equals("Conditional")						// current GNode is a Conditional
			&& node.size == 2										// has 2 children (1st is a PresenceCondition)
			&& node.get(1) instanceof GNode
			&& (node.get(1) as GNode).name.equals("Declaration")	// 2nd child is a variable Declaration
		) {
//			debug(node)
			
			val presenceCondition = node.presenceCondition.and(node.get(0) as PresenceCondition)
			
			
			// Put the current PresenceCondition into the PC-ID map (if it does not already exist)
			// and assign a new number ID to it.
			pcidmap.put_pcid(presenceCondition, pcidmap.size.toString)
			
			
			val declaration = node.get(1) as GNode
			val declaringList = declaration.get(0) as GNode
			val simpleDeclarator = declaringList.filter(GNode).findFirst[name.equals("SimpleDeclarator")]
			val variableName = simpleDeclarator.get(0).toString
			val newName = variableName + "_V" + pcidmap.get_id(presenceCondition)
			
			// Add the variable in the declaration to the variable scope
			// because this Declaration node hasn't been visited yet.
			if(!variableExists(variableName)) {
				addVariable(variableName)
			}
			
			// Find the bottom-most declaration of the current variable name (bottom-most scope)
			// and add the current PresenceCondition to it.
			getPCListForLastDeclaration(variableName).add(node.get(0) as PresenceCondition)
			
			// Create a TopDownStrategy to
			// rename the declared variable and
			// rewrite variable use in the assignment expression.
			val tdn = new TopDownStrategy
			tdn.register(new RenameVariableRule(newName))
//			println(''':> «variableName»''')
//			println(''':> «node.presenceCondition»''')
//			println(''':> «node.get(0) as PresenceCondition»''')
//			println(''':> «node.presenceCondition.and(node.get(0) as PresenceCondition)»''')
//			println
			tdn.register(new RewriteVariableUseRule(localVariableScopes, presenceCondition, pcidmap))
			val newNode = tdn.transform(node.get(1)) as GNode
			
			// Return the new Declaration without the surrounding Conditional.
			return newNode
		} else if(#["ExpressionStatement"]
			.contains(node.name)
		) {
			debug(node)
			
			val tdn = new TopDownStrategy
			tdn.register(new RewriteVariableUseRule(localVariableScopes, node.guard, pcidmap))
			val newNode = tdn.transform(node) as GNode

//			println("newn:> " + newNode.get(1).printCode)
			
			return newNode
//		} else if(!#["TranslationUnit", "ExternalDeclarationList", "DeclaringList",
//			"SimpleDeclarator"]
//			.contains(node.name)
//		) {
//			println('''unhandled: ReconfigureVariableRule of «node.name»''')
//			node
		} else {
			node
		}
	}

}
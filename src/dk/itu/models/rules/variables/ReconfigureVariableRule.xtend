package dk.itu.models.rules.variables

import dk.itu.models.strategies.TopDownStrategy
import java.util.HashMap
import xtc.lang.cpp.CTag
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.tree.GNode
import xtc.util.Pair

import static extension dk.itu.models.Extensions.*

class ReconfigureVariableRule extends dk.itu.models.rules.ScopingRule {
	
	private val HashMap<PresenceCondition, String> pcidmap
	
	new (HashMap<PresenceCondition, String> pcidmap) {
		this.pcidmap = pcidmap
	}
	
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
	
	override dispatch Object transform(GNode node) {
		// Update the variable scopes and declarations.
		(this as dk.itu.models.rules.ScopingRule).transform(node)

		// Visit a variable Declaration under a Conditional.
		if	(  node.name.equals("Conditional")						// current GNode is a Conditional
			&& node.size == 2										// has 2 children (1st is a PresenceCondition)
			&& node.get(1) instanceof GNode
			&& (node.get(1) as GNode).name.equals("Declaration")	// 2nd child is a variable Declaration
		) {
			
			val presenceCondition = node.presenceCondition.and(node.get(0) as PresenceCondition)
			
			// Put the current PresenceCondition into the PC-ID map (if it does not already exist)
			// and assign a new number ID to it.
			pcidmap.put_pcid(presenceCondition, pcidmap.size.toString)
			
			val declaration = node.get(1) as GNode
			val declaringList = declaration.get(0) as GNode
			val variableName =
				if ((declaringList.get(1) as GNode).name.equals("SimpleDeclarator")) {
					(declaringList.get(1) as GNode).get(0).toString
				} else if(
					(declaringList.get(1) as GNode).name.equals("UnaryIdentifierDeclarator")
					&& (declaringList.get(1) as GNode).get(1) instanceof GNode
					&& ((declaringList.get(1) as GNode).get(1) as GNode).name.equals("ArrayDeclarator")
					&& ((declaringList.get(1) as GNode).get(1) as GNode).get(0) instanceof GNode
					&& (((declaringList.get(1) as GNode).get(1) as GNode).get(0) as GNode).name.equals("SimpleDeclarator")
				) {
					(((declaringList.get(1) as GNode).get(1) as GNode).get(0) as GNode).get(0).toString
				} else throw new Exception("ReconfigureVariableRule: unknown location of variable name")
//				else ((declaringList.get(1) as GNode).get(1) as GNode).get(0).toString
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
			val newNode = tdn.transform(node.get(1)) as GNode
			
			newNode.setProperty("OriginalPC", node.presenceCondition.and(node.get(0) as PresenceCondition))
			
			// Return the new Declaration without the surrounding Conditional.
			return newNode
		} else if(#["ExpressionStatement", "Initializer", "ReturnStatement"]
			.contains(node.name)
		) {
			val tdn = new TopDownStrategy
			tdn.register(new RewriteVariableUseRule(localVariableScopes, node.presenceCondition, pcidmap))
			val newNode = tdn.transform(node) as GNode
	
			return newNode
			
		} else if (node.name.equals("SelectionStatement")) {
			
//			println
//			println('''----------------------''')
//			println('''- ReconfigureVariable ''')
//			println('''----------------------''')
//			println('''- «node»''')
//			println('''----------------------''')
//			node.forEach[
//				println('''- «it»''')]
////			println('''- «variableName» -> «newName»''')
////			println('''- «node.get(1).printAST»''')
////			println('''- «newNode.printCode»''')

			val tdn = new TopDownStrategy
			tdn.register(new RewriteVariableUseRule(localVariableScopes, node.presenceCondition, pcidmap))
			val newNode = tdn.transform(node.get(2)) as GNode
			
			if (!newNode.printAST.equals(node.get(2).printAST))
				return GNode::createFromPair(
					"SelectionStatement",
					node.map[
						if (node.indexOf(it) == 2) newNode
						else it].toPair)
				else return node
		}
		
		node
	}

}
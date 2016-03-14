package dk.itu.models.rules

import xtc.lang.cpp.CTag
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.tree.GNode
import xtc.util.Pair
import java.util.List
import java.util.HashMap
import dk.itu.models.strategies.TopDownStrategy
import java.util.Map

class ReconfigureVariableRule extends Rule {
	
	val public pcidmap = new HashMap<PresenceCondition, String>
	val public variableToPCMap = new HashMap<String, List<PresenceCondition>>
	
	override dispatch PresenceCondition transform(PresenceCondition cond) {
		cond
	}

	override dispatch Language<CTag> transform(Language<CTag> lang) {
		lang
	}

	override dispatch Pair<?> transform(Pair<?> pair) {
		pair
	}

	override dispatch Object transform(GNode node) {
		if(node.name.equals("Conditional")
			&& node.size == 2
			&& !((node.get(0) as PresenceCondition).toString.equals("1"))
			&& node.get(1) instanceof GNode
			&& (node.get(1) as GNode).name.equals("Declaration")
		) {
			// check
    	    for(GNode parent : ancestors) {
    	    	if(parent.name.equals("FunctionDefinition"))
    	    		return node;
    	    }
			
			val presenceCondition = node.get(0) as PresenceCondition
			val variableDecl = node.get(1) as GNode
			
			pcidmap.put_pcid(presenceCondition, pcidmap.size.toString)
			
			val declaringList = variableDecl.get(0) as GNode
			val simpleDeclarator = declaringList.filter(GNode).findFirst[name.equals("SimpleDeclarator")]
			val variableName = simpleDeclarator.get(0).toString
			val newVariableName = variableName + "_V" + pcidmap.get_id(presenceCondition)
			
			variableToPCMap.put_var(variableName, presenceCondition)
			
			val tdn = new TopDownStrategy
			tdn.register(new RenameVariableRule(newVariableName))
//			tdn.register(new RewriteVariableUseRule(variableToPCMap, pcidmap))
			val newNode = tdn.transform(variableDecl)
			
			newNode
		}
		else if (node.name.equals("AdditiveExpression")
			&& !ancestors.last.name.equals("Conditional")) {
				val tdn = new TopDownStrategy
				tdn.register(new RewriteVariableUseRule(variableToPCMap, pcidmap))
				val newNode = tdn.transform(node)
				
				newNode
		}
		else
			node
	}
	
	static def void put_pcid (HashMap<PresenceCondition, String> map, PresenceCondition pc, String id) {
		if (map.keySet.findFirst[is(pc)] == null)
			map.put(pc, id)
	}
	
	static def String get_id (HashMap<PresenceCondition, String> map, PresenceCondition pc) {
		map.get(map.keySet.findFirst[is(pc)])
	}
	
	static def void put_var(HashMap<String, List<PresenceCondition>> map, String key, PresenceCondition pc) {
		if (!map.containsKey(key))
			map.put(key, newArrayList(pc))
		else if (!map.get(key).contains(pc))
			map.get(key).add(pc)
	}

}
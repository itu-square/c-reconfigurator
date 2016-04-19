package dk.itu.models.rules.phase4functions

import dk.itu.models.rules.AncestorGuaranteedRule
import dk.itu.models.strategies.TopDownStrategy
import java.util.HashMap
import java.util.List
import xtc.lang.cpp.CTag
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.tree.GNode
import xtc.tree.Node
import xtc.util.Pair

class ReconfigureFunctionRule extends AncestorGuaranteedRule {
	
	private val HashMap<PresenceCondition, String> pcidmap
	
	val public fmap = new HashMap<String, List<PresenceCondition>>
	
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
	
	static def void put_function (HashMap<String, List<PresenceCondition>> map, String key, PresenceCondition pc) {
		if (!map.containsKey(key))
			map.put(key, newArrayList(pc))
		else if (!map.get(key).contains(pc))
			map.get(key).add(pc)
	}
	
	
	
	
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
		if(node.name.equals("Conditional")
			&& node.size == 2
			&& node.get(1) instanceof GNode
			&& (node.get(1) as GNode).name.equals("FunctionDefinition")
		) {
			val presenceCondition = node.get(0) as PresenceCondition

			val functionDefinition = node.get(1) as GNode
			
			pcidmap.put_pcid(presenceCondition, pcidmap.size.toString)
			
			val functionPrototype = functionDefinition.get(0) as GNode
			
			val functionDeclarator =
				if ((functionPrototype.get(1) as GNode).name.equals("FunctionDeclarator"))
					(functionPrototype.get(1) as GNode)
				else ((functionPrototype.get(1) as GNode).get(1) as GNode)
			
			val simpleDeclarator = functionDeclarator.get(0) as GNode
			val functionName = simpleDeclarator.get(0).toString
			val newName = functionName + "_V" + pcidmap.get_id(presenceCondition)
			
			fmap.put_function(functionName, presenceCondition)


			val tdn = new TopDownStrategy
			tdn.register(new RenameFunctionRule(newName))
			tdn.register(new RewriteFunctionCallRule(fmap, node.presenceCondition, pcidmap))
			val newNode = tdn.transform(node) as GNode
			
			(newNode.get(1) as Node).setProperty("OriginalPC", node.presenceCondition.and(node.get(0) as PresenceCondition))

			return newNode.get(1)
		}
		else if (
			node.name.equals("FunctionDefinition") &&
			!ancestors.last.name.equals("Conditional")
		) {
			val tdn = new TopDownStrategy
			tdn.register(new RewriteFunctionCallRule(fmap, node.presenceCondition, pcidmap))
			val newNode = tdn.transform(node) as GNode
			return newNode
		}
		node
	}

}
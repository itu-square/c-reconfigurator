package dk.itu.models.rules

import xtc.lang.cpp.CTag
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.tree.GNode
import xtc.util.Pair
import java.util.List
import java.util.HashMap
import dk.itu.models.Reconfigurator

class ExtractFunctionRule extends Rule {
	
	val public functions = new HashMap<String, List<PresenceCondition>>
	
	def void put(HashMap<String, List<PresenceCondition>> map, String key, PresenceCondition pc) {
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

	override dispatch Pair<?> transform(Pair<?> pair) {
		pair
	}
	
	def private PresenceCondition currentPC() {
		var pc = Reconfigurator.presenceConditionManager.newPresenceCondition(true)
		val guards = ancestors.filter[it.name == "Conditional"]
		for(GNode guard : guards){
			
			val child = ancestors.get(ancestors.indexOf(guard) + 1)
			val condition = guard.findLast [
				it instanceof PresenceCondition && guard.indexOf(it) < guard.indexOf(child)
			]
			pc = pc.and(condition as PresenceCondition)
		}
		pc
	}
	
	override dispatch Object transform(GNode node) {
		if(node.name.equals("FunctionPrototype")) {
//			println(node.printCode)
//			println(ancestors.last)
//			println(currentPC)
//			println
			functions.put(node.printCode, currentPC)
		}
		
		node
	}

}
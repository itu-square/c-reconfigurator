package dk.itu.models

import java.util.HashMap
import java.util.List
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import java.util.ArrayList

class DeclarationPCMap {
	protected val HashMap<String, List<PresenceCondition>> map
	
	new () {
		map = new HashMap<String, List<PresenceCondition>>
	}
	
	public def void newDeclaration(String name) {
		map.putIfAbsent(name, new ArrayList<PresenceCondition>)
	}
		
	public def boolean containsDeclaration(String name) {
		map.keySet.contains(name)
	}
	
	public def List<PresenceCondition> pcList (String name) {
		map.get(name)
	}
	
	public def void putPC (String name, PresenceCondition pc) {
		map.putIfAbsent(name, new ArrayList<PresenceCondition>)
		map.get(name).add(pc)
	}
}
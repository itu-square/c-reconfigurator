package dk.itu.models.utils

import java.util.ArrayList
import java.util.HashMap
import java.util.List
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import java.util.AbstractMap.SimpleEntry

class DeclarationPCMap {
	
	protected val HashMap<String, List<SimpleEntry<Declaration,PresenceCondition>>> map
	
	new () {
		map = new HashMap<String, List<SimpleEntry<Declaration,PresenceCondition>>>
	}
	
	public def void put (Declaration declaration, PresenceCondition pc) {
		map.putIfAbsent(declaration.name, new ArrayList<SimpleEntry<Declaration, PresenceCondition>>)
		
		map.get(declaration.name).add(new SimpleEntry(declaration, pc))
	}
	
	public def Declaration get (String name, PresenceCondition pc) {
		val list = map.get(name)
		if (list != null) {
			val pair = list.findFirst[pair | pair.value.is(pc)]
			if (pair != null)
				pair.key
		}
	} 
	
	public def boolean containsDeclaration(String name) {
		map.keySet.contains(name)
	}
	
	public def List<SimpleEntry<Declaration, PresenceCondition>> pcList (String name) {
		map.get(name)
	}
}
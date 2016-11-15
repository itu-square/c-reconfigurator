package dk.itu.models.utils

import java.util.AbstractMap.SimpleEntry
import java.util.ArrayList
import java.util.HashMap
import java.util.List
import java.util.Set
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition

class DeclarationPCMap {
	
	protected val HashMap<String, List<SimpleEntry<Declaration,PresenceCondition>>> map
	
	new () {
		map = new HashMap<String, List<SimpleEntry<Declaration,PresenceCondition>>>
	}
	
	public def void put (String name, Declaration declaration, PresenceCondition pc) {
		map.putIfAbsent(name, new ArrayList<SimpleEntry<Declaration, PresenceCondition>>)
		
		map.get(name).add(new SimpleEntry(declaration, pc))
	}
	
//	public def Declaration get (String name, PresenceCondition pc) {
//		val list = map.get(name)
//		if (list != null) {
//			val pair = list.findFirst[pair | !pair.value.BDD.imp(pc.BDD).isZero]
//			if (pair != null)
//				pair.key
//		}
//	} 
	
	public def boolean containsDeclaration(String name) {
		map.containsKey(name)
	}
	
	public def List<SimpleEntry<Declaration, PresenceCondition>> declarationList(String name) {
		map.get(name)
	}
	
	public def int size() {
		map.size
	}
	
	public def Set<String> names() {
		map.keySet
	}
	
	public def void clear() {
		map.clear
	}
}
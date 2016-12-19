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
	
	private def fix(String name) {
		if (name.contains(" ")) {
			val n = map.keySet.findFirst[key |
				key.contains(" ")
				&& name.split(" ").size == key.split(" ").size
				&& key.split(" ").toSet.equals(name.split(" ").toSet)
			]
			if (n != null)
				return n
		}
		return name
	}
	
	public def void put (String name, Declaration declaration, PresenceCondition pc) {
		val fixedName = fix(name)
		if (!map.containsKey(fixedName))
			map.put(fixedName, new ArrayList<SimpleEntry<Declaration, PresenceCondition>>)
		
		map.get(fixedName).add(new SimpleEntry(declaration, pc))
	}
	
	public def void rem(String name, String variantName) {
		val fixedName = fix(name)
		if (map.containsKey(fixedName)) {
			val variant = map.get(fixedName).findFirst[pair | pair.key.name.equals(variantName)]
			if (variant != null) {
				map.get(fixedName).remove(variant)
			}
			
			if (map.get(fixedName).size == 0) {
				map.remove(fixedName)
			}
		}
	}
	
	public def boolean containsDeclaration(String name) {
		val fixedName = fix(name)
		map.containsKey(fixedName)
	}
	
	public def List<SimpleEntry<Declaration, PresenceCondition>> declarationList(String name) {
		val fixedName = fix(name)
		map.get(fixedName)
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
	
	public def Set<String> maps() {
		map.keySet.map['''«it» -> {«FOR x : map.get(it) SEPARATOR ", "»«x.key.name»«ENDFOR»}'''].toSet
	}
}
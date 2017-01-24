package dk.itu.models.utils

import java.util.AbstractMap.SimpleEntry
import java.util.ArrayList
import java.util.HashMap
import java.util.List
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition

class DeclarationPCMap {
	
	protected val HashMap<Declaration, List<SimpleEntry<Declaration,PresenceCondition>>> map
	
	new () {
		map = new HashMap<Declaration, List<SimpleEntry<Declaration,PresenceCondition>>>
	}
	
	def String fix(String name) {
		if (name.contains(" ")) {
			val n = map.keySet.findFirst[declaration |
				declaration.name.contains(" ")
				&& name.split(" ").size == declaration.name.split(" ").size
				&& declaration.name.split(" ").toSet.equals(name.split(" ").toSet)
			]
			if (n != null)
				return n.name
		}
		return name
	}
	
	public def void put (Declaration declaration, Declaration variant, PresenceCondition pc) {
		if (!map.keySet.exists[it.name.equals(declaration.name)])
			map.put(declaration, new ArrayList<SimpleEntry<Declaration, PresenceCondition>>)
		
		if (variant != null)
			map.get(declaration).add(new SimpleEntry(variant, pc))
	}
	
	public def Declaration getDeclaration(String name) {
		map.keySet.sortBy[it.name].findFirst[declaration | declaration.name.equals(fix(name))]
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
		map.keySet.exists[key | key.name.equals(fix(name))]
	}
	
	public def List<SimpleEntry<Declaration, PresenceCondition>> declarationList(String name) {
		map.get(getDeclaration(name))
	}
	
	public def int size() {
		map.size
	}
	
	public def Iterable<String> names() {
		map.keySet.map[name].sort
	}
	
	public def void clear() {
		map.clear
	}
}
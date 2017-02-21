package dk.itu.models.utils

import xtc.tree.GNode
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition

class DeclarationScope {
	
	public val GNode node
	protected val DeclarationPCMap map = new DeclarationPCMap
	
	new (GNode node) {
		this.node = node
	}
	
	public def void put(Declaration declaration) {
		map.put(declaration)
	}
	
	public def void put (Declaration declaration, Declaration variant, PresenceCondition pc) {
		map.put(declaration, variant, pc)
	}
	
	public def Declaration getDeclaration(String name) {
		map.getDeclaration(name)
	}
	
}
package dk.itu.models.utils

import java.util.ArrayList
import java.util.Stack
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.tree.GNode
import java.util.List

class DeclarationScopeStack {
	
	protected val Stack<DeclarationScope> stack = new Stack<DeclarationScope>
	
	public def pushScope(GNode node) {
		stack.push(new DeclarationScope(node))
	}
	
	public def clearScopes(ArrayList<GNode> ancestors) {
		stack.removeIf(scope | !ancestors.contains(scope) && scope.node.name.equals("TranslationUnit"))
	}
	
	public def void put(Declaration declaration) {
		stack.peek.put(declaration)
	}
	
	public def void put (Declaration declaration, Declaration variant, PresenceCondition pc) {
		stack.peek.put(declaration, variant, pc)
	}
	
	public def Declaration getDeclaration(String name) {
		
		var Declaration declaration
		
		for (DeclarationScope scope : stack) {
			declaration = scope.getDeclaration(name)
			if (declaration != null)
				return declaration
		}
		
		return declaration
	}
	
	public def List<DeclarationPCPair> declarationList(String name) {
		stack.map[declarationList(name)].filterNull.flatten.toList
	}

}
package dk.itu.models.strategies

import java.util.ArrayList
import xtc.tree.GNode
import dk.itu.models.rules.AncestorGuaranteedRule

abstract class AncestorGuaranteedStrategy extends Strategy {
	
	protected val ArrayList<GNode> ancestors
	
	new() {
		super()
		this.ancestors = new ArrayList<GNode>
	}
	
	public def register(AncestorGuaranteedRule rule) {
		rules.add(rule.init(ancestors))
	}
}
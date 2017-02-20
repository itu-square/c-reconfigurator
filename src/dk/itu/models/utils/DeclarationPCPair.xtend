package dk.itu.models.utils

import xtc.lang.cpp.PresenceConditionManager.PresenceCondition

import static extension dk.itu.models.Extensions.*

class DeclarationPCPair {
	
	public val Declaration declaration;
	public val PresenceCondition pc;
	
	new (Declaration declaration, PresenceCondition pc) {
		this.declaration = declaration;
		this.pc = pc;
	}
	
	public override toString() {
		declaration + " = " + pc.PCtoCPPexp
	}
}
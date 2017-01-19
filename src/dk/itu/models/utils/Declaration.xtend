package dk.itu.models.utils

abstract class Declaration {
	
	public val String name
	
	new (String name) {
		this.name = name
	}
	
	override public def String toString() { 
	    return name
	}
}
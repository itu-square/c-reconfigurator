package dk.itu.models.utils

class VariableDeclaration extends Declaration {
	
	public val TypeDeclaration type
	
	new (String name, TypeDeclaration type) {
		super(name)
		this.type = type
	}
	
}
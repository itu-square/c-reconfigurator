package dk.itu.models.utils

import java.util.ArrayList

class TypeDeclaration extends Declaration {
	
	public val TypeDeclaration refType
	public val ArrayList<VariableDeclaration> fields
	
	new (String name, TypeDeclaration refType) {
		super(name)
		this.refType = refType
		this.fields = new ArrayList<VariableDeclaration>
	}
	
}
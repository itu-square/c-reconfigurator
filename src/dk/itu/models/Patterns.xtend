package dk.itu.models

import xtc.lang.cpp.CTag
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.lang.cpp.Syntax.Text
import xtc.tree.GNode
import xtc.tree.Node

import static extension dk.itu.models.Extensions.*

class Patterns {
	
	public static def boolean isTypeDeclaration(GNode node) {
		node.name.equals("Declaration")
		&& node.getDescendantNode[
			it instanceof Language<?>
			&& (it as Language<CTag>).tag.equals(CTag::TYPEDEF)
		] != null
	}
	
	public static def boolean isTypeDeclarationWithVariability(GNode node) {
		node.name.equals("Conditional")
		&& node.size == 2
		
		&& (node.get(0) instanceof PresenceCondition)
		
		&& (node.get(1) instanceof GNode)
		&& (node.get(1) as GNode).isTypeDeclaration
	}
	
	public static def String getNameOfTypeDeclaration(GNode node) {
		val simpleDeclarator = node.getDescendantNode("SimpleDeclarator")
		return (simpleDeclarator.get(0) as Text<CTag>).toString
	}
	
	public static def String getTypeOfTypeDeclaration(GNode node) {
		
		var typeName = ""
		var bds = ((node.get(0) as GNode).get(0) as GNode)
		while (
			bds.name.equals("BasicDeclarationSpecifier")
		){
			if (
				(bds.last instanceof GNode)
				&& (bds.last as GNode).name.equals("SignedKeyword")
			) {
				typeName = (bds.last as GNode).head.toString + " " + typeName
			} else if (bds.last instanceof Language<?>) {
				typeName = (bds.last as Language<CTag>).toString + " " + typeName
			}
			bds = bds.get(0) as GNode
		}
		return typeName.trim
	}
	
	
	
	
	
	
	public static def boolean isStructDeclarationWithVariability(GNode node) {
		   node.name.equals("Conditional")
		&& node.size == 2
		
		&& (node.get(1) instanceof GNode)
		&& (node.get(1) as GNode).name.equals("Declaration")
		&& (node.get(1) as GNode).size == 2
		
		&& ((node.get(1) as GNode).get(0) instanceof GNode)
		&& ((node.get(1) as GNode).get(0) as GNode).name.equals("SUETypeSpecifier")
		&& ((node.get(1) as GNode).get(0) as GNode).size == 1

		&& (((node.get(1) as GNode).get(0) as GNode).get(0) instanceof GNode)
		&& (((node.get(1) as GNode).get(0) as GNode).get(0) as GNode).name.equals("StructSpecifier")
	} 
	
	
	
	
	
	
	
	public static def boolean isFunctionDefinition(GNode node) {
		node.name.equals("FunctionDefinition")
	}
	
	public static def boolean isFunctionDefinitionWithVariability(GNode node) {
		node.name.equals("Conditional")
		&& node.size == 2
		
		&& (node.get(0) instanceof PresenceCondition)
		
		&& (node.get(1) instanceof GNode)
		&& (node.get(1) as GNode).isFunctionDefinition
	}
	
	public static def String getNameOfFunctionDefinition(GNode node) {
		val simpleDeclarator = node.getDescendantNode("SimpleDeclarator")
		return (simpleDeclarator.get(0) as Text<?>).toString
	}
	
	public static def String getTypeOfFunctionDefinition(GNode node) {
		val functionPrototype = node.getDescendantNode("FunctionPrototype")
		val typeNode = functionPrototype.get(0) as Node
		
		if (typeNode.name.equals("BasicDeclarationSpecifier")) {
			val basicTypeSpecifier = (typeNode as GNode)
			return (basicTypeSpecifier.get(1) as Language<CTag>).toString	
		} else
		
		if (typeNode.name.equals("BasicTypeSpecifier")) {
			val basicTypeSpecifier = (typeNode as GNode)
			return (basicTypeSpecifier.get(1) as Language<CTag>).toString	
		} else
		
		if (typeNode.name.equals("TypedefDeclarationSpecifier")) {
			val typedefDeclarationSpecifier = (typeNode as GNode)
			return (typedefDeclarationSpecifier.get(1) as Text<CTag>).toString	
		} else
		
		if (typeNode.name.equals("TypedefTypeSpecifier")) {
			val typedefTypeSpecifier = (typeNode as GNode)
			return (typedefTypeSpecifier.findFirst[it instanceof Text<?>] as Text<CTag>).toString	
		} else

		if (typeNode instanceof Language<?>) {
			return (typeNode as Language<CTag>).toString
		} else
		
		{
			println
			println(node.printAST)
			throw new Exception("case not handled")
		}
	}
		

	
	
	
	
	public static def boolean isVariableDeclaration(GNode node) {
		node.name.equals("Declaration")
	}
	
	public static def boolean isVariableDeclarationWithVariability(GNode node) {
		node.name.equals("Conditional")
		&& node.size == 2
		
		&& (node.get(0) instanceof PresenceCondition)
		
		&& (node.get(1) instanceof GNode)
		&& (node.get(1) as GNode).isVariableDeclaration
	}
	
	public static def String getNameOfVariableDeclaration(GNode node) {
		val simpleDeclarator = node.getDescendantNode("SimpleDeclarator")
		return (simpleDeclarator.get(0) as Text<?>).toString
	}
	
	public static def String getTypeOfVariableDeclaration(GNode node) {
		val declaringList = node.getDescendantNode("DeclaringList")
		var typeNode = declaringList.get(0)
		
		if (typeNode instanceof Language<?>) {
			return (declaringList.get(0) as Language<CTag>).toString
		} else
		
		if (typeNode instanceof GNode && (typeNode as GNode).name.equals("BasicDeclarationSpecifier")) {
			return ((typeNode as GNode).get(1) as Language<CTag>).toString
		} else
		
		if (typeNode instanceof GNode && (typeNode as GNode).name.equals("TypedefTypeSpecifier")) {
			return (typeNode as GNode).getDescendantNode[
				it instanceof Text<?>
				&& (it as Text<CTag>).tag.equals(CTag::TYPEDEFname)
			].toString
		} else
		
		if (typeNode instanceof GNode && (typeNode as GNode).name.equals("BasicTypeSpecifier")) {
			return (typeNode as GNode).filter[it instanceof Language<?>].map[it.toString].join(" ")
		} else 
		
		{
			println
			println(node.printAST)
			throw new Exception("case not handled")
		}
	}
	
	
	
	
	
	public static def boolean isParameterDeclaration(GNode node) {
		   node.name.equals("ParameterIdentifierDeclaration")
	}
	
	public static def String getNameOfParameterDeclaration(GNode node) {
		val simpl = node.getDescendantNode("SimpleDeclarator")
		return (simpl.get(0) as Text<?>).toString
	}
	
	public static def String getTypeOfParameterDeclaration(GNode node) {
		var typeName =
			if (node.get(0) instanceof Language<?>)
				(node.get(0) as Language<CTag>).toString
			else if (node.get(0) instanceof GNode && (node.get(0) as GNode).name.equals("TypedefTypeSpecifier"))
				((node.get(0) as GNode).get(0) as Text<?>).toString
			else if (node.get(0) instanceof GNode && (node.get(0) as GNode).name.equals("BasicTypeSpecifier"))
				((node.get(0) as GNode).get(1) as Language<CTag>).toString
			else
				throw new Exception("case not handled")
		
		var declarator = (node.get(1) as GNode)
		while (declarator.name.equals("UnaryIdentifierDeclarator")) {
			typeName = typeName + (declarator.get(0)).toString
			declarator = (declarator.get(1) as GNode)
		}
		return typeName
	}
	
	
}
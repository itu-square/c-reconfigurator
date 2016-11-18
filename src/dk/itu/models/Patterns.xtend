package dk.itu.models

import java.util.List
import xtc.lang.cpp.CTag
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.lang.cpp.Syntax.Text
import xtc.tree.GNode

import static extension dk.itu.models.Extensions.*

class Patterns {
	
	public static def boolean isTypeDeclaration(GNode node) {
		      node.name.equals("Declaration")
		&&    node.size == 2
		
		&&   (node.get(0) instanceof GNode)
		&&   (node.get(0) as GNode).name.equals("DeclaringList")
		
		&&  ((node.get(0) as GNode).get(0) instanceof GNode)
		&&  ((node.get(0) as GNode).get(0) as GNode).name.equals("BasicDeclarationSpecifier")
		
		&&  ((node.get(0) as GNode).get(0) as GNode).getDescendantNode("DeclarationQualifierList") != null
		
		&& (((node.get(0) as GNode).get(0) as GNode).getDescendantNode("DeclarationQualifierList").get(0) instanceof Language<?>)
		&& (((node.get(0) as GNode).get(0) as GNode).getDescendantNode("DeclarationQualifierList").get(0) as Language<CTag>).tag.equals(CTag::TYPEDEF)
		
		&&  ((node.get(0) as GNode).get(1) instanceof GNode)
		&&  ((node.get(0) as GNode).get(1) as GNode).name.equals("SimpleDeclarator")
	}
	
	public static def boolean isTypeDeclarationWithVariability(GNode node) {
		node.name.equals("Conditional")
		&& node.size == 2
		
		&& (node.get(0) instanceof PresenceCondition)
		
		&& (node.get(1) instanceof GNode)
		&& (node.get(1) as GNode).isTypeDeclaration
	}
	
	public static def String getNameOfTypeDeclaration(GNode node) {
		val simpleDeclarator = ((node.get(0) as GNode).get(1) as GNode)
		return (simpleDeclarator.get(0) as Text<?>).toString
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
		
		&& (node.get(0) instanceof GNode)
		&& (node.get(0) as GNode).name.equals("FunctionPrototype")
		
		&& (
			(  ((node.get(0) as GNode).get(0) instanceof GNode)
			&& ((node.get(0) as GNode).get(0) as GNode).name.equals("BasicTypeSpecifier"))
		||
			(  ((node.get(0) as GNode).get(0) instanceof Language<?>))
		   )
		
		&& ((node.get(0) as GNode).get(1) instanceof GNode)
		&& ((node.get(0) as GNode).get(1) as GNode).name.equals("FunctionDeclarator")
		
		&& (((node.get(0) as GNode).get(1) as GNode).get(0) instanceof GNode)
		&& (((node.get(0) as GNode).get(1) as GNode).get(0) as GNode).name.equals("SimpleDeclarator")
	}
	
	public static def String getNameOfFunctionDefinition(GNode node) {
		val simpleDeclarator = (((node.get(0) as GNode).get(1) as GNode).get(0) as GNode)
		return (simpleDeclarator.get(0) as Text<?>).toString
	}
	
	public static def String getTypeOfFunctionDefinition(GNode node) {
		if (  ((node.get(0) as GNode).get(0) instanceof GNode)
			&& ((node.get(0) as GNode).get(0) as GNode).name.equals("BasicTypeSpecifier")
		) {
			val basicTypeSpecifier = ((node.get(0) as GNode).get(0) as GNode)
			return (basicTypeSpecifier.get(1) as Language<CTag>).toString	
		} else

		if (  ((node.get(0) as GNode).get(0) instanceof Language<?>)
		) {
			return ((node.get(0) as GNode).get(0) as Language<CTag>).toString
		} else
		
		throw new Exception("case not handled")
	}
	
	
	
	
	
	
	public static def boolean isFunctionDeclaration(GNode node) {
		node.name.equals("Declaration")
		&& node.getDescendantNode("FunctionDeclarator") != null
	}
	
	public static def boolean isVariableDeclarationWithVariability(GNode node, List<GNode> ancestors) {
		ancestors.size >= 1
		&& #["ExternalDeclarationList", "DeclarationOrStatementList"].contains(ancestors.last.name)
		&& node.name.equals("Conditional")
		&& node.get(1) instanceof GNode
		&& #["Declaration", "DeclarationExtension"].contains((node.get(1) as GNode).name)
		&& !(node.get(1) as GNode).containsTypedef
		&& node.getDescendantNode("SUETypeSpecifier") == null
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
			(declaringList.get(0) as Language<CTag>).toString
		} else
		if (typeNode instanceof GNode && (typeNode as GNode).name.equals("TypedefTypeSpecifier") ) {
			((typeNode as GNode).get(0) as Text<?>).toString
		} else
		throw new Exception("Patterns: case not handled.")
	}
	
	
	
	
	
	public static def boolean isParameterDeclaration(GNode node) {
		   node.name.equals("ParameterIdentifierDeclaration")
		&& node.size == 3
		
		&& (node.get(0) instanceof Language<?>)
		
		&& ((
			   (node.get(1) instanceof GNode)
			&& (node.get(1) as GNode).name.equals("SimpleDeclarator")
		) || (
			   (node.get(1) instanceof GNode)
			&& (node.get(1) as GNode).name.equals("UnaryIdentifierDeclarator")
		))
	}
	
	public static def String getNameOfParameterDeclaration(GNode node) {
		var declarator = (node.get(1) as GNode)
		while (!declarator.name.equals("SimpleDeclarator")) {
			declarator = (declarator.get(1) as GNode)
		}
		return (declarator.get(0) as Text<?>).toString
	}
	
	public static def String getTypeOfParameterDeclaration(GNode node) {
		var typeName = (node.get(0) as Language<CTag>).toString
		var declarator = (node.get(1) as GNode)
		while (declarator.name.equals("UnaryIdentifierDeclarator")) {
			typeName = typeName + (declarator.get(0)).toString
			declarator = (declarator.get(1) as GNode)
		}
		return typeName
	}
	
	
}
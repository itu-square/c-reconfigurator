package dk.itu.models

import xtc.lang.cpp.CTag
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.lang.cpp.Syntax.Text
import xtc.tree.GNode
import xtc.tree.Node

import static extension dk.itu.models.Extensions.*
import java.util.ArrayDeque

class Patterns {
	
	
	public static def boolean isStructTypeDeclaration(GNode node) {
		node.name.equals("Declaration")
		&& node.getDescendantNode[
			it instanceof Language<?>
			&& (it as Language<CTag>).tag.equals(CTag::TYPEDEF)
		] != null
		&& node.getDescendantNode("StructSpecifier") != null
	}
	
	public static def boolean isStructTypeDeclarationWithVariability(GNode node) {
		node.name.equals("Conditional")
		&& node.size == 2
		
		&& (node.get(0) instanceof PresenceCondition)
		
		&& (node.get(1) instanceof GNode)
		&& (node.get(1) as GNode).isStructTypeDeclaration
	}
	
	public static def String getNameOfStructTypeDeclaration(GNode node) {
		val simpleDeclarator = node.getDescendantNode("SimpleDeclarator")
		return (simpleDeclarator.get(0) as Text<CTag>).toString
	}
	
	public static def String getTypeOfStructTypeDeclaration(GNode node) {
		val structSpecifier = node.getDescendantNode("StructSpecifier")
		return (structSpecifier.get(0) as Language<CTag>).toString + " "
			+ ((structSpecifier.get(1) as GNode).get(0) as Text<CTag>).toString
	}
	
	
	
	
	
	public static def boolean isEnumDeclaration(GNode node) {
		node.name.equals("Declaration")
		&& node.getDescendantNode("EnumSpecifier") != null
	}
	
	public static def String getNameOfEnumDeclaration(GNode node) {
		val enumSpecifier = node.getDescendantNode("EnumSpecifier")
		if (
			enumSpecifier != null
			&& enumSpecifier.get(0) instanceof Language<?>
			&& enumSpecifier.get(1) instanceof GNode
			&& (enumSpecifier.get(1) as GNode).name.equals("IdentifierOrTypedefName")
		) {
			return (enumSpecifier.get(0) as Language<CTag>).toString + " "
				+ ((enumSpecifier.get(1) as GNode).get(0) as Text<?>).toString
		} else {
			println
			println(node.printCode)
			println(node.printAST)
			throw new Exception("case not handled")
		}
	}
	
	
	
	
	
	
	public static def boolean isTypeDeclaration(GNode node) {
		node.name.equals("Declaration")
		&& node.getDescendantNode[
			it instanceof Language<?>
			&& (it as Language<CTag>).tag.equals(CTag::TYPEDEF)
		] != null
		&& node.getDescendantNode("StructSpecifier") == null
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
		
		if (typeNode.name.equals("SUETypeSpecifier")) {
			return typeNode.printCode
		}

		if (typeNode instanceof Language<?>) {
			return (typeNode as Language<CTag>).toString
		} else
		
		{
			println
			println(node.printCode)
			println(node.printAST)
			throw new Exception("case not handled")
		}
	}
		

	
	
	
	
	public static def boolean isVariableDeclaration(GNode node) {
		node.name.equals("Declaration")
		&& node.getDescendantNode[
			it instanceof Language<?>
			&& (it as Language<CTag>).tag.equals(CTag::TYPEDEF)
		] == null
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
	
	private static def String getTypeByTraversal(GNode node) {
		
		val ArrayDeque<Object> elements = new ArrayDeque<Object>
		elements.add(node)
		
		var type = ""
		
		while (!elements.empty) {
			val current = elements.remove
			
			if (current instanceof Language<?>) {
				if (!current.toString.equals("static")
					&& !current.toString.equals("extern")
					&& !current.toString.equals("const")
				) {
					if (current.toString.equals("*")) {
						type += current.toString
					} else {
						type += " " + current.toString
					}
				}
			}

			else if (current instanceof GNode) {
				if ((current as GNode).name.equals("SimpleDeclarator")) {
					elements.clear
				} else {
					for (Object e : current.toList.reverseView)
						elements.addFirst(e)
				}
			}
		}
		return type.trim
	}
	
	public static def String getTypeOfVariableDeclaration(GNode node) {
		val declaringList = node.getDescendantNode("DeclaringList") as GNode
		return getTypeByTraversal(declaringList)
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
			if (node.get(0) instanceof Language<?>) {
				(node.get(0) as Language<CTag>).toString
			} else if (node.get(0) instanceof GNode && (node.get(0) as GNode).name.equals("TypedefTypeSpecifier")) {
				if ((node.get(0) as GNode).get(0) instanceof Text<?>)
					((node.get(0) as GNode).get(0) as Text<?>).toString
				else if ((node.get(0) as GNode).get(1) instanceof Text<?>)
					((node.get(0) as GNode).get(1) as Text<?>).toString
			} else if (node.get(0) instanceof GNode && (node.get(0) as GNode).name.equals("BasicTypeSpecifier")) {
				((node.get(0) as GNode).get(1) as Language<CTag>).toString
			} else if (node.get(0) instanceof GNode && (node.get(0) as GNode).name.equals("SUETypeSpecifier")) {
				(node.get(0) as GNode).get(0).printCode
			} else {
				throw new Exception("case not handled")
			}
		
		var declarator = (node.get(1) as GNode)
		while (declarator.name.equals("UnaryIdentifierDeclarator")) {
			typeName = typeName + (declarator.get(0)).toString
			declarator = (declarator.get(1) as GNode)
		}
		return typeName
	}
	
	
}
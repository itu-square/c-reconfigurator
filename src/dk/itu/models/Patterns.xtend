package dk.itu.models

import dk.itu.models.utils.DeclarationPCMap
import java.util.ArrayDeque
import java.util.ArrayList
import xtc.lang.cpp.CTag
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.lang.cpp.Syntax.Text
import xtc.tree.GNode
import xtc.tree.Node

import static extension dk.itu.models.Extensions.*

class Patterns {
	
	
	public static def boolean isStructDeclaration(GNode node) {
		node.name.equals("Declaration")
		&& node.getDescendantNode[
			it instanceof Language<?>
			&& (it as Language<CTag>).tag.equals(CTag::TYPEDEF)
		] == null
		&& node.getDescendantNode("StructSpecifier") != null
	}
	
	public static def String getNameOfStructDeclaration(GNode node) {
		val structSpecifier = node.getDescendantNode("StructSpecifier")
		return (structSpecifier.get(0) as Language<?>).toString + " "
			+ ((structSpecifier.get(1) as GNode).get(0) as Text<?>).toString
	}




	
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
		((node.getDescendantNode("DeclaringList")
			.findFirst[(it instanceof GNode) && (it as GNode).name.equals("SimpleDeclarator")] as GNode)
			.get(0) as Text<CTag>).toString
	}
	
	public static def String getTypeOfStructTypeDeclaration(GNode node) {
		val structSpecifier = node.getDescendantNode("StructSpecifier")
		
		val name = 
		if (structSpecifier.getDescendantNode("IdentifierOrTypedefName") != null) {
			(structSpecifier.get(0) as Language<CTag>).toString + " "
			+ (structSpecifier.getDescendantNode("IdentifierOrTypedefName").get(0) as Text<CTag>).toString
		} else {
			(structSpecifier.get(0) as Language<CTag>).toString
		}
		return name
	}
	
	
	
	
	
	public static def boolean isEnumDeclaration(GNode node) {
		node.name.equals("Declaration")
		&& node.getDescendantNode("EnumSpecifier") != null
		&& node.getDescendantNode("EnumeratorList") != null
	}
	
	public static def boolean isEnumDeclarationWithVariability(GNode node) {
		node.name.equals("Conditional")
		&& node.size == 2
		
		&& (node.get(0) instanceof PresenceCondition)
		
		&& (node.get(1) instanceof GNode)
		&& (node.get(1) as GNode).isEnumDeclaration
	}
	
	public static def boolean isNamedEnumDeclaration(GNode node) {
		node.isEnumDeclaration
		&& node.getDescendantNode("IdentifierOrTypedefName") != null
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
		#["Declaration", "DeclarationExtension"].contains(node.name)
		&& node.getDescendantNode[
			it instanceof Language<?>
			&& (it as Language<CTag>).tag.equals(CTag::TYPEDEF)
		] !== null
		&& node.getDescendantNode("StructSpecifier") === null
	}
	
	public static def boolean isTypeDeclarationWithVariability(GNode node) {
		node.name.equals("Conditional")
		&& node.size == 2
		
		&& (node.get(0) instanceof PresenceCondition)
		
		&& (node.get(1) instanceof GNode)
		&& (node.get(1) as GNode).isTypeDeclaration
	}
	
	public static def boolean isTypeDeclarationWithTypeVariability(GNode node, DeclarationPCMap typeDeclarations) {
		node.isTypeDeclaration
		&& !node.getBooleanProperty("refTypeVariabilityHandled")
		&& typeDeclarations.declarationList(node.getTypeOfTypeDeclaration).size > 0
	}
	
	public static def String getNameOfTypeDeclaration(GNode node) {
		val simpleDeclarator = node.getDescendantNode("SimpleDeclarator")
		val name = (simpleDeclarator.get(0) as Text<CTag>).toString
		return name
	}
	
	public static def String getTypeOfTypeDeclaration(GNode node) {
		return getTypeByTraversal(node.getDescendantNode("DeclaringList") as GNode)
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
	
	
	
	
	
	
	
	
	public static def boolean isFunctionDeclaration(GNode node) {
		node.name.equals("Declaration")
		&& node.getDescendantNode("FunctionDeclarator") != null
	} 
	
	public static def boolean isFunctionDeclarationWithVariability(GNode node) {
		node.name.equals("Conditional")
		&& node.size == 2
		
		&& (node.get(0) instanceof PresenceCondition)
		
		&& (node.get(1) instanceof GNode)
		&& (node.get(1) as GNode).isFunctionDeclaration
	}
	
	public static def boolean isFunctionDeclarationWithSignatureVariability(GNode node, DeclarationPCMap typeDeclarations) {
		node.isFunctionDeclaration
		&& node.getVariableSignatureTypesOfFunctionDeclaration(typeDeclarations).size > 0
	}
	
	public static def String getNameOfFunctionDeclaration(GNode node) {
		val simpleDeclarator = node.getDescendantNode("SimpleDeclarator")
		return (simpleDeclarator.get(0) as Text<?>).toString
	}
	
	public static def String getTypeOfFunctionDeclaration(GNode node) {
		val declaringList = node.getDescendantNode("DeclaringList") as GNode
		return getTypeByTraversal(declaringList)
	}
	
	public static def Iterable<String> getSignatureTypesOfFunctionDeclaration(GNode node) {
		val types = new ArrayList<String>
		types.add(node.getTypeOfFunctionDeclaration)
		val parameterList = node.getDescendantNode("ParameterList")
		if (parameterList != null) {
			types.addAll(parameterList.filter[(it instanceof GNode) && (it as GNode).isParameterDeclaration].map[(it as GNode).getTypeOfParameterDeclaration])
		}
		return types
	}
	
	public static def Iterable<String> getVariableSignatureTypesOfFunctionDeclaration(GNode node, DeclarationPCMap typeDeclarations) {
		node.getSignatureTypesOfFunctionDeclaration.filter[typeName |
			typeDeclarations.declarationList(typeName).size != 0]
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
		return getTypeByTraversal((node.getDescendantNode("FunctionPrototype") as GNode).get(0) as GNode)
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
					&& !current.toString.equals("typedef")
					&& !current.toString.equals("__restrict")
					&& !current.toString.equals("*")
				) {
					type += " " + current.toString
				}
			}

			else if (current instanceof GNode) {
				if (#["SimpleDeclarator", "PostfixIdentifierDeclarator", "ParameterTypedefDeclarator"].contains((current as GNode).name)) {
					elements.clear
				} else if (#["TypeQualifier"].contains((current as GNode).name)) {
					// do nothing
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
		return getTypeByTraversal(node)
	}
	
	
}
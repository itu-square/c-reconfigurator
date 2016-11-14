package dk.itu.models

import dk.itu.models.utils.DeclarationPCMap
import dk.itu.models.utils.TypeDeclaration
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
		&& node.size == 2
		
		&& (node.get(0) instanceof GNode)
		&& (node.get(0) as GNode).name.equals("DeclaringList")
		
		&& ((node.get(0) as GNode).get(0) instanceof GNode)
		&& ((node.get(0) as GNode).get(0) as GNode).name.equals("BasicDeclarationSpecifier")
		
		&& (((node.get(0) as GNode).get(0) as GNode).get(0) instanceof GNode)
		&& (((node.get(0) as GNode).get(0) as GNode).get(0) as GNode).name.equals("DeclarationQualifierList")
		
		&& ((((node.get(0) as GNode).get(0) as GNode).get(0) as GNode).get(0) instanceof Language<?>)
		&& ((((node.get(0) as GNode).get(0) as GNode).get(0) as GNode).get(0) as Language<CTag>).tag.equals(CTag::TYPEDEF)
		
		&& ((node.get(0) as GNode).get(1) instanceof GNode)
		&& ((node.get(0) as GNode).get(1) as GNode).name.equals("SimpleDeclarator")
	}
	
	public static def String getNameOfTypeDeclaration(GNode node) {
		val simpleDeclarator = ((node.get(0) as GNode).get(1) as GNode)
		return (simpleDeclarator.get(0) as Text<?>).toString
	}
	
//	private static def String getTypeNameFromBasicDeclarationSpecifier(GNode node) {
//		var typeName = ""
//		var bds = node
//		while (
//			bds.name.equals("BasicDeclarationSpecifier")
//		){
//			if (
//				(bds.last instanceof GNode)
//				&& (bds.last as GNode).name.equals("SignedKeyword")
//			) {
//				typeName = (bds.last as GNode).head.toString + " " + typeName
//			} else if (bds.last instanceof Language<?>) {
//				typeName = (bds.last as Language<CTag>).toString + " " + typeName
//			}
//			bds = bds.get(0) as GNode
//		}
//		return typeName
//	}
//	
//	public static def TypeDeclaration getTypeDeclaration(GNode node, DeclarationPCMap typeDeclarations, PresenceCondition pc) {
//		
//		val declaration = if (
//			   node.name.equals("Declaration")
//			&& node.size == 2
//		) node else throw new Exception
//		
//		val declaringList = if (
//			   (declaration.get(0) instanceof GNode)
//			&& (declaration.get(0) as GNode).name.equals("DeclaringList")
//			&& (declaration.get(0) as GNode).size == 5
//		) declaration.get(0) as GNode else throw new Exception
//		
//		val basicDeclarationSpecifier = if (
//			   (declaringList.get(0) instanceof GNode)
//			&& (declaringList.get(0) as GNode).name.equals("BasicDeclarationSpecifier")
//			&& (declaringList.get(0) as GNode).size == 2
//		) declaringList.get(0) as GNode else throw new Exception
//		
//		val oldTypeName = basicDeclarationSpecifier.typeNameFromBasicDeclarationSpecifier
//		var oldTypeDeclaration = typeDeclarations.get(oldTypeName, pc) as TypeDeclaration
//		
//		if (oldTypeDeclaration == null) {
//			oldTypeDeclaration = new TypeDeclaration(oldTypeName, null)
//			typeDeclarations.put(oldTypeDeclaration, pc)
//		}
//		
//		val simpleDeclarator = if (
//			   (declaringList.get(1) instanceof GNode)
//			&& (declaringList.get(1) as GNode).name.equals("SimpleDeclarator")
//			&& (declaringList.get(1) as GNode).size == 1
//		) declaringList.get(1) as GNode else throw new Exception
//		
//		val newTypeName = (simpleDeclarator.get(0) as Text<?>).toString
//		
//		return new TypeDeclaration(newTypeName, oldTypeDeclaration)
//	}
	
	
	
	
	
	
	
	
	
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
	
	public static def boolean isVariableDeclarationWithVariability(GNode node, List<GNode> ancestors) {
		ancestors.size >= 1
		&& #["ExternalDeclarationList", "DeclarationOrStatementList"].contains(ancestors.last.name)
		&& node.name.equals("Conditional")
		&& node.get(1) instanceof GNode
		&& #["Declaration", "DeclarationExtension"].contains((node.get(1) as GNode).name)
		&& !(node.get(1) as GNode).containsTypedef
		&& node.getDescendantNode("SUETypeSpecifier") == null
	}
		

	public static def boolean isVariableDeclarationOrParamenter(GNode node) {
		#["Declaration", "ParameterDeclaration"].contains(node.name)
		&& (node.size > 1 || node.get(0) instanceof GNode)
		&& node.getDescendantNode("FunctionDeclarator") == null
		&& node.getDescendantNode("EnumSpecifier") == null
		&& (node.getDescendantNode("StructOrUnionSpecifier") == null || node.getDescendantNode("SimpleDeclarator") != null)
		&& (node.getDescendantNode("TypedefTypeSpecifier") == null || node.getDescendantNode("SimpleDeclarator") != null)
		&& !(node.name.equals("ParameterDeclaration") && node.getDescendantNode("SimpleDeclarator") == null)
		&& !node.containsTypedef
		&& node.getDescendantNode("SUETypeSpecifier") == null
	}
	
	
	
	
	
	
	
	
	
	public static def boolean isVariableDeclaration(GNode node) {
		   node.name.equals("Declaration")
		&& node.size == 2
		
		&& (node.get(0) instanceof GNode)
		&& (node.get(0) as GNode).name.equals("DeclaringList")
		&& (node.get(0) as GNode).size == 5
		
		&& ((node.get(0) as GNode).get(0) instanceof GNode)
		&& ((node.get(0) as GNode).get(0) as GNode).name.equals("TypedefTypeSpecifier")
		
		&& ((node.get(0) as GNode).get(1) instanceof GNode)
		&& ((node.get(0) as GNode).get(1) as GNode).name.equals("SimpleDeclarator")
	}
	
	public static def String getNameOfVariableDeclaration(GNode node) {
		val simpleDeclarator = ((node.get(0) as GNode).get(1) as GNode)
		return (simpleDeclarator.get(0) as Text<?>).toString
	}
	
	public static def String getTypeOfVariableDeclaration(GNode node) {
		val typedefTypeSpecifier = ((node.get(0) as GNode).get(0) as GNode)
		return (typedefTypeSpecifier.get(0) as Text<?>).toString
	}
	
	
}
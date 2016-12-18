package dk.itu.models.rules

import dk.itu.models.Reconfigurator
import dk.itu.models.utils.DeclarationPCMap
import dk.itu.models.utils.FunctionDeclaration
import dk.itu.models.utils.TypeDeclaration
import dk.itu.models.utils.VariableDeclaration
import java.util.AbstractMap.SimpleEntry
import java.util.ArrayList
import xtc.lang.cpp.CTag
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.tree.GNode
import xtc.util.Pair

import static extension dk.itu.models.Extensions.*
import static extension dk.itu.models.Patterns.*

abstract class ScopingRule extends AncestorGuaranteedRule {
	
	protected val ArrayList<SimpleEntry<GNode,DeclarationPCMap>> variableDeclarationScopes
	protected val DeclarationPCMap typeDeclarations
	protected val DeclarationPCMap functionDeclarations
	
	new () {
		super()
		this.variableDeclarationScopes = new ArrayList<SimpleEntry<GNode,DeclarationPCMap>>
		this.typeDeclarations = new DeclarationPCMap
		this.functionDeclarations = new DeclarationPCMap
	}
	
	protected def addVariableDeclarationScope(GNode node) {
		this.variableDeclarationScopes.add(new SimpleEntry<GNode,DeclarationPCMap>(node, new DeclarationPCMap))
	}
	
	protected def clearVariableDeclarationScopes() {
		while (
			variableDeclarationScopes.size > 0 &&
			!ancestors.contains(variableDeclarationScopes.last.key)
		) {
			variableDeclarationScopes.remove(variableDeclarationScopes.size - 1)
		}
	}
	
	protected def addVariable(String name, VariableDeclaration variable, PresenceCondition pc) {
		variableDeclarationScopes.last.value.put(name, variable, pc)
	}
	
	protected def variableExists(String name) {
		variableDeclarationScopes.exists[ se |
			se.value.containsDeclaration(name)
		]
	}
	
	def PresenceCondition transform(PresenceCondition cond) {
		clearVariableDeclarationScopes
		cond
	}

	def Language<CTag> transform(Language<CTag> lang) {
		clearVariableDeclarationScopes
		lang
	}

	def Pair<Object> transform(Pair<Object> pair) {
		clearVariableDeclarationScopes
		pair
	}
	
	def Object transform(GNode node) {
		clearVariableDeclarationScopes
		if (#["ExternalDeclarationList", "FunctionDefinition", "FunctionDeclarator", "CompoundStatement"].contains(node.name)) {
			addVariableDeclarationScope(node)
		} else if (node.name.equals("TranslationUnit")) {
			debug("\n" + "TranslationUnit")
			this.functionDeclarations.clear
			this.typeDeclarations.clear
			
			#[	"void",
				"char",					"signed char",				"unsigned char",
				"short",				"short int",				"signed short",
				"signed short int",		"unsigned short",			"unsigned short int",
				"int",					"signed",					"signed int",
				"unsigned",				"unsigned int",				"long",
				"long int",				"signed long",				"signed long int",
				"unsigned long",		"unsigned long int",		"long long",
				"long long int",		"signed long long",			"signed long long int",
				"unsigned long long",	"unsigned long long int",	"float",
				"double",				"long double",				"_Bool"
			].forEach[ typeName |
				this.typeDeclarations.put(
					typeName,
					new TypeDeclaration(typeName, null),
					Reconfigurator::presenceConditionManager.newPresenceCondition(true))
				this.typeDeclarations.put(
					typeName + "*",
					new TypeDeclaration(typeName + "*", null),
					Reconfigurator::presenceConditionManager.newPresenceCondition(true))
				this.typeDeclarations.put(
					typeName + "**",
					new TypeDeclaration(typeName + "**", null),
					Reconfigurator::presenceConditionManager.newPresenceCondition(true))]
			
		} else if(#["Declaration", "DeclaringList", "SUEDeclarationSpecifier",
			"DeclarationQualifierList", "StructOrUnionSpecifier", "StructOrUnion",
			"IdentifierOrTypedefName", "SimpleDeclarator", "ArrayDeclarator",
			"ArrayAbstractDeclarator", "InitializerOpt", "Initializer", "StringLiteralList",
			"Conditional", "BasicDeclarationSpecifier", "SignedKeyword", "ParameterTypedefDeclarator",
			"DeclarationExtension", "DeclarationQualifier", "TypeQualifier", "AttributeSpecifier",
			"AttributeKeyword", "AttributeListOpt", "AttributeList", "Word",
			"TypedefDeclarationSpecifier", "FunctionPrototype", "FunctionSpecifier",
			"PostfixingFunctionDeclarator", "ParameterTypeListOpt",
			"ParameterTypeList", "ParameterList", "ParameterDeclaration", "BasicTypeSpecifier",
			"TypeQualifierList", "TypeQualifier", "ConstQualifier",
			"DeclarationOrStatementList", "ReturnStatement", "MultiplicativeExpression",
			"CastExpression", "TypeName", "TypedefTypeSpecifier", "PrimaryIdentifier",
			"SelectionStatement", "RelationalExpression", "ExpressionStatement", "AssignmentExpression",
			"AssignmentOperator", "FunctionCall", "ExpressionList", "PrimaryExpression",
			"ConditionalExpression", "LogicalAndExpression", "UnaryExpression", "Unaryoperator",
			"ShiftExpression", "UnaryIdentifierDeclarator", "AttributeSpecifierListOpt",
			"AttributeSpecifierList", "AttributeExpressionOpt", "AbstractDeclarator",
			"UnaryAbstractDeclarator", "EqualityExpression", "LogicalORExpression", "Declaration",
			"RestrictQualifier", "AndExpression", "InclusiveOrExpression", "IterationStatement",
			"AdditiveExpression", "StatementAsExpression", "Subscript", "Decrement", "GotoStatement",
			"BreakStatement", "LabeledStatement", "Increment", "MatchedInitializerList",
			"DesignatedInitializer", "Designation", "DesignatorList", "Designator",
			"ContinueStatement", "Expression", "SUETypeSpecifier", "StructDeclarationList",
			"StructDeclaration", "StructDeclaringList", "StructDeclarator", "IndirectSelection",
			"EmptyDefinition", "EnumSpecifier", "EnumeratorList", "Enumerator", "EnumeratorValueOpt",
			"PostfixIdentifierDeclarator", "PostfixingAbstractDeclarator", "CleanTypedefDeclarator",
			"CleanPostfixTypedefDeclarator", "DirectSelection", "AssemblyExpressionOpt",
			"LocalLabelDeclarationListOpt", "ParameterAbstractDeclaration", "ParameterIdentifierDeclaration",
			"ExpressionOpt"]
				.contains(node.name)
		) {
			// no scope
		} else {
			println
			println('''---------------''')
			println('''- ScopingRule -''')
			println('''---------------''')
			ancestors.forEach[
				println('''- «it.name»''')]
			println((node as GNode).printAST)
			println
			throw new Exception("ScopingRule: possible scope : " + node.name + ".")
		}
		
		
		
		
		
		
		if (node.isFunctionDefinition) {
			debug("isFunctionDefinition")
			// get current PC and names
			val name = node.nameOfFunctionDefinition
			val type = node.typeOfFunctionDefinition
			val pc = node.presenceCondition
			
			// get registered type declaration
			if (!typeDeclarations.containsDeclaration(type))
				throw new Exception('''ScopingRule: type declaration «type» not found.''')

			val typeDeclarationList = typeDeclarations.declarationList(type)
			
			if (typeDeclarationList.size == 1) {
				val typeDeclaration = typeDeclarationList.get(0).key as TypeDeclaration
				val functionDeclaration = new FunctionDeclaration(name, typeDeclaration)
				functionDeclarations.put(name, functionDeclaration, pc)
			} else {
				throw new Exception("ScopingRule: not handled: multiple type declarations.")
			}
		} else
		if (node.isTypeDeclaration) {
			debug("isTypeDeclaration")
			// get current PC and names
			val name = node.getNameOfTypeDeclaration
			val type = node.getTypeOfTypeDeclaration
			val pc = node.presenceCondition

			// get registered type declaration
			if (!typeDeclarations.containsDeclaration(type))
				throw new Exception('''ScopingRule: type declaration «type» not found.''')
			
			val typeDeclarationList = typeDeclarations.declarationList(type)
			
			if (typeDeclarationList.size == 1) {
				val typeDeclaration = typeDeclarationList.get(0).key as TypeDeclaration
				
				var newTypeDeclaration = new TypeDeclaration(name, typeDeclaration)
				typeDeclarations.put(name, newTypeDeclaration, pc)
				
				newTypeDeclaration = new TypeDeclaration(name + "*", typeDeclaration)
				typeDeclarations.put(name + "*", newTypeDeclaration, pc)
				
				newTypeDeclaration = new TypeDeclaration(name + "**", typeDeclaration)
				typeDeclarations.put(name + "**", newTypeDeclaration, pc)
			} else {
				throw new Exception("ScopingRule: not handled: multiple type declarations.")
			}
		} else
//		if (node.isFunctionDeclaration) {
//			var declarator = node.getDescendantNode("SimpleDeclarator")
//			if (declarator == null)
//				declarator = node.getDescendantNode("ParameterTypedefDeclarator")
//			
//			throw new UnsupportedOperationException("Function Declaration")
////			functionDeclarations.newDeclaration(declarator.get(0).toString)
//		}
//
//		
//		
//		// VARIABLE DECLARATIONS
//		
//		// variable of type
//		else if (
//			     (node.name.equals("Declaration"))
//			&&   (node.get(0) instanceof GNode)
//			&&   (node.get(0) as GNode).name.equals("DeclaringList")
//			&&  ((node.get(0) as GNode).get(0) instanceof Language<?>)
//			&&  ((node.get(0) as GNode).get(1) instanceof GNode)
//			&&  ((node.get(0) as GNode).get(1) as GNode).name.equals("SimpleDeclarator")
//			&& (((node.get(0) as GNode).get(1) as GNode).get(0) instanceof Text<?>)
//		) {
//			
//			val varName = (((node.get(0) as GNode).get(1) as GNode).get(0) as Text<?>).toString
//			val varTypeName = ((node.get(0) as GNode).get(0) as Language<?>).toString
//			val varPC = guard(node)
//			val varType = typeDeclarations.get(varTypeName, varPC) as TypeDeclaration
//			
//			addVariable(new VariableDeclaration(varName, varType), varPC)
//			
//		} else
		if (node.isVariableDeclaration) {
			debug("isVariableDeclaration")
			// get current PC and names
			val pc = node.presenceCondition
			val name = node.getNameOfVariableDeclaration
			val type = node.getTypeOfVariableDeclaration
			
			// get registered type declaration
			if (!typeDeclarations.containsDeclaration(type))
				throw new Exception('''ScopingRule: type declaration «type» not found.''')
			
			val typeDeclarationList = typeDeclarations.declarationList(type)
			
			if (typeDeclarationList.size == 1) {
				val typeDeclaration = typeDeclarationList.get(0).key as TypeDeclaration
				val variableDeclaration = new VariableDeclaration(name, typeDeclaration)
				addVariable(name, variableDeclaration, pc)
			} else {
				throw new Exception("ScopingRule: not handled: multiple type declarations.")
			}
			
		} else
		if (node.isParameterDeclaration) {
			debug("isParameterDeclaration")
			// get current PC and names
			val pc = node.presenceCondition
			val name = node.getNameOfParameterDeclaration
			val type = node.getTypeOfParameterDeclaration
			
			// get registered type declaration
			if (!typeDeclarations.containsDeclaration(type))
				throw new Exception('''ScopingRule: type declaration «type» not found.''')
			
			val typeDeclarationList = typeDeclarations.declarationList(type)
			
			if (typeDeclarationList.size == 1) {
				val typeDeclaration = typeDeclarationList.get(0).key as TypeDeclaration
				val variableDeclaration = new VariableDeclaration(name, typeDeclaration)
				addVariable(name, variableDeclaration, pc)
			} else {
				throw new Exception("ScopingRule: not handled: multiple type declarations.")
			}
			
		} else
		if (#[	"AbstractDeclarator", "AdditiveExpression", "AndExpression", "ArrayAbstractDeclarator",
			"ArrayDeclarator", "AssemblyExpressionOpt", "AssignmentExpression", "AssignmentOperator",
			"AttributeExpressionOpt", "AttributeKeyword", "AttributeList", "AttributeListOpt",
			"AttributeSpecifier", "AttributeSpecifierList", "AttributeSpecifierListOpt",
				"BasicDeclarationSpecifier", "BasicTypeSpecifier", "BreakStatement",
				"CastExpression", "CleanPostfixTypedefDeclarator", "CleanTypedefDeclarator",
			"CompoundStatement", "Conditional", "ConditionalExpression", "ConstQualifier",
			"ContinueStatement",
				"DeclarationExtension", "DeclarationOrStatementList", "DeclarationQualifier",
			"DeclarationQualifierList", "DeclaringList", "Decrement", "DesignatedInitializer",
			"Designation", "Designator", "DesignatorList", "DirectSelection",
				"EqualityExpression", "EmptyDefinition", "EnumSpecifier", "Enumerator", "EnumeratorList",
			"EnumeratorValueOpt", "Expression", "ExpressionList", "ExpressionOpt", "ExpressionStatement",
			"ExternalDeclarationList",
				"FunctionCall", "FunctionDeclarator", "FunctionPrototype", "FunctionSpecifier",
				"GotoStatement",
				"IdentifierOrTypedefName", "InclusiveOrExpression", "Increment", "IndirectSelection",
			"Initializer", "InitializerOpt", "IterationStatement",
				"LabeledStatement", "LocalLabelDeclarationListOpt", "LogicalAndExpression",
			"LogicalORExpression",
				"MatchedInitializerList", "MultiplicativeExpression",
				"ParameterList", "ParameterTypedefDeclarator", "ParameterTypeList", "ParameterTypeListOpt",
			"PostfixIdentifierDeclarator", "PostfixingAbstractDeclarator", "PostfixingFunctionDeclarator",
			"PrimaryExpression", "PrimaryIdentifier",
				"RelationalExpression", "ReturnStatement", "RestrictQualifier",
				"SelectionStatement", "ShiftExpression", "SignedKeyword", "SimpleDeclarator", "Subscript",
			"SUEDeclarationSpecifier", "SUETypeSpecifier", "StatementAsExpression", "StringLiteralList",
			"StructDeclaration", "StructDeclarationList", "StructDeclarator", "StructDeclaringList",
			"StructOrUnion", "StructOrUnionSpecifier",
				"TranslationUnit", "TypedefDeclarationSpecifier", "TypedefTypeSpecifier", "TypeName",
			"TypeQualifier", "TypeQualifierList",
			 	"UnaryAbstractDeclarator", "UnaryExpression", "UnaryIdentifierDeclarator", "Unaryoperator",
				"Word"].contains(node.name)
			|| (node.name.equals("ParameterDeclaration") && (node.size == 1 || !(node instanceof GNode)))
			|| (node.name.equals("ParameterDeclaration") && node.getDescendantNode("EnumSpecifier") != null )
			|| (node.name.equals("Declaration") && node.getDescendantNode("EnumSpecifier") != null )
			|| (node.name.equals("Declaration") && node.getDescendantNode("StructOrUnionSpecifier") != null )
			|| (node.name.equals("ParameterDeclaration") && node.getDescendantNode("SimpleDeclarator") == null)
			|| (node.name.equals("ParameterAbstractDeclaration") && node.size == 1)
		) {
			// no declaration
		} else {
			println
			println('''---------------''')
			println('''- ScopingRule -''')
			println('''---------------''')
			ancestors.forEach[
				println('''- «it.name»''')]
			println((node as GNode).printAST)
			println
			throw new Exception("ScopingRule: possible declaration : " + node.name + ".")
		}
		
		node
	}
	
}
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
import dk.itu.models.Settings

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
	
	protected def addVariable(VariableDeclaration variable, VariableDeclaration variant, PresenceCondition pc) {
		variableDeclarationScopes.last.value.put(variable, variant, pc)
	}
	
	protected def variableExists(String name) {
		variableDeclarationScopes.variableExists(name)
	}
	
	public static def variableExists(
		ArrayList<SimpleEntry<GNode,DeclarationPCMap>> variableDeclarationScopes,
		String name
	) {
		variableDeclarationScopes.exists[ se | se.value.containsDeclaration(name) ]
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
		
		var temp = ancestors.last.toPair
		while (temp != pair) {
			transform(temp.head)
			temp = temp.tail
		}
		
		pair
	}
	
	def Object transform(GNode node) {
		clearVariableDeclarationScopes
		if (#["ExternalDeclarationList", "FunctionDefinition", "FunctionDeclarator", "CompoundStatement"].contains(node.name)) {
			addVariableDeclarationScope(node)
		} else if (node.name.equals("TranslationUnit")) {
			debug("\n\n")
			debug("TranslationUnit", true)
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
					new TypeDeclaration(typeName, null),
					null,
					Reconfigurator::presenceConditionManager.newPresenceCondition(true))
				if (typeName.contains("signed")) {
					this.typeDeclarations.put(
						new TypeDeclaration(typeName.replace("signed", "__signed__"), null),
						null,
						Reconfigurator::presenceConditionManager.newPresenceCondition(true))
				}
			]
			
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
			"ExpressionOpt", "StructSpecifier", "BitFieldSizeOpt", "VolatileQualifier", "UnionSpecifier"]
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
			debug
			debug("   isFunctionDefinition", true)
			// get current PC and names
			val name = node.nameOfFunctionDefinition
			val type = node.typeOfFunctionDefinition
			val pc = node.presenceCondition
			debug('''   - [«name»] of [«type»]''')
			
			// get registered type declaration
			if (!typeDeclarations.containsDeclaration(type))
				throw new Exception('''ScopingRule: type declaration [«type»] of [«name»] not found.''')

			val typeDeclarationList = typeDeclarations.declarationList(type)
			
			if (typeDeclarationList.size == 1) {
				val typeDeclaration = typeDeclarationList.get(0).key as TypeDeclaration
				val functionDeclaration = new FunctionDeclaration(name, typeDeclaration)
				functionDeclarations.put(functionDeclaration, null, pc)
			} else {
				throw new Exception("ScopingRule: not handled: multiple type declarations.")
			}
		} else
		if (node.isTypeDeclaration) {
			val pc = node.presenceCondition
			val typeName = node.getNameOfTypeDeclaration
			val refTypeName = node.getTypeOfTypeDeclaration
			
			var refTypeDeclaration = typeDeclarations.getDeclaration(refTypeName) as TypeDeclaration
			
			if (refTypeDeclaration == null)
				throw new Exception('''ScopingRule: type declaration [«refTypeName»] of [«typeName»] not found.''')
			
			var newTypeDeclaration = new TypeDeclaration(typeName, refTypeDeclaration)
			typeDeclarations.put(newTypeDeclaration, null, pc)
		} else
		
		if (node.isStructDeclaration) {
			debug("   isStructDeclaration", true)
			// get current PC and names
			val name = node.getNameOfStructDeclaration
			val pc = node.presenceCondition
			debug('''   - [«name»]''')
			
			// get registered type declaration
			if (!typeDeclarations.containsDeclaration(name)) {
				var newTypeDeclaration = new TypeDeclaration(name, null)
				typeDeclarations.put(newTypeDeclaration, null, pc)
			}
		} else
		
		if (
			node.isStructTypeDeclaration
		) {
			val pc = node.presenceCondition
			val name = node.getNameOfStructTypeDeclaration
			val type = node.getTypeOfStructTypeDeclaration
			
			if (type.equals("struct")) {
				val typeDeclaration = new TypeDeclaration(name, null)
				typeDeclarations.put(typeDeclaration, null, pc)
			} else {
				throw new Exception("Case not handled")
			}
		} else
		
		if (node.isNamedEnumDeclaration) {
			debug
			debug("   isEnumDeclaration", true)
			
			val pc = node.presenceCondition
			val name = node.nameOfEnumDeclaration
			debug('''   - [«name»]''')
			
			this.typeDeclarations.put(new TypeDeclaration(name, null), null, pc)
		} else
		
		if (
			node.isEnumDeclaration
		) {
			// TODO something
		} else
		
		if (
			node.isVariableDeclaration
			&& !node.getNameOfVariableDeclaration.startsWith(Settings::reconfiguratorIncludePlaceholder)
		) {
			val pc = node.presenceCondition
			val varName = node.getNameOfVariableDeclaration
			val typeName = node.getTypeOfVariableDeclaration
			
			val typeDeclaration = typeDeclarations.getDeclaration(typeName) as TypeDeclaration
			
			// get registered type declaration
			if (typeDeclaration == null)
				throw new Exception('''ScopingRule: type declaration [«typeName»] not found.''')
			
			val variableDeclaration = new VariableDeclaration(varName, typeDeclaration)
			addVariable(variableDeclaration, null, pc)
		} else
		
		if (node.isParameterDeclaration) {
			val pc = node.presenceCondition
			val name = node.getNameOfParameterDeclaration
			val type = node.getTypeOfParameterDeclaration
			
			if (typeDeclarations.declarationList(type).findFirst[key.name.equals(type)] != null) {
				val typeDeclaration = typeDeclarations.declarationList(type).findFirst[key.name.equals(type)].key as TypeDeclaration
				val variableDeclaration = new VariableDeclaration(name, typeDeclaration)
				addVariable(variableDeclaration, null, pc)
			}
		} else
		
		if (#[	"AbstractDeclarator", "AdditiveExpression", "AndExpression", "ArrayAbstractDeclarator",
			"ArrayDeclarator", "AssemblyExpressionOpt", "AssignmentExpression", "AssignmentOperator",
			"AttributeExpressionOpt", "AttributeKeyword", "AttributeList", "AttributeListOpt",
			"AttributeSpecifier", "AttributeSpecifierList", "AttributeSpecifierListOpt",
				"BasicDeclarationSpecifier", "BasicTypeSpecifier", "BreakStatement", "BitFieldSizeOpt",
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
			"PrimaryExpression", "PrimaryIdentifier", "ParameterAbstractDeclaration",
				"RelationalExpression", "ReturnStatement", "RestrictQualifier",
				"SelectionStatement", "ShiftExpression", "SignedKeyword", "SimpleDeclarator", "Subscript",
			"SUEDeclarationSpecifier", "SUETypeSpecifier", "StatementAsExpression", "StringLiteralList",
			"StructDeclaration", "StructDeclarationList", "StructDeclarator", "StructDeclaringList",
			"StructOrUnion", "StructOrUnionSpecifier", "StructSpecifier",
				"TranslationUnit", "TypedefDeclarationSpecifier", "TypedefTypeSpecifier", "TypeName",
			"TypeQualifier", "TypeQualifierList",
			 	"UnaryAbstractDeclarator", "UnaryExpression", "UnaryIdentifierDeclarator", "Unaryoperator",
			 "UnionSpecifier",
			 	"VolatileQualifier",
				"Word"].contains(node.name)
			|| (node.name.equals("ParameterDeclaration") && (node.size == 1 || !(node instanceof GNode)))
			|| (node.name.equals("ParameterDeclaration") && node.getDescendantNode("EnumSpecifier") != null )
			|| (node.name.equals("Declaration") && node.getDescendantNode("EnumSpecifier") != null )
			|| (node.name.equals("Declaration") && node.getDescendantNode("StructOrUnionSpecifier") != null )
			|| (node.name.equals("ParameterDeclaration") && node.getDescendantNode("SimpleDeclarator") == null)
			|| (node.name.equals("ParameterAbstractDeclaration") && node.size == 1)
			|| (node.isVariableDeclaration
				&& node.getNameOfVariableDeclaration.startsWith(Settings::reconfiguratorIncludePlaceholder))
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
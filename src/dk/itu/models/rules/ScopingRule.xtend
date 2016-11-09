package dk.itu.models.rules

import dk.itu.models.Settings
import dk.itu.models.utils.Declaration
import dk.itu.models.utils.DeclarationPCMap
import dk.itu.models.utils.TypeDeclaration
import dk.itu.models.utils.VariableDeclaration
import java.util.AbstractMap.SimpleEntry
import java.util.ArrayList
import java.util.List
import xtc.lang.cpp.CTag
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.lang.cpp.Syntax.Text
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
		
//		this.typeDeclarations.put(
//			new TypeDeclaration("int", null),
//			Reconfigurator::presenceConditionManager.newPresenceCondition(true))
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
	
	protected def addVariable(VariableDeclaration variable, PresenceCondition pc) {
		variableDeclarationScopes.last.value.put(variable, pc)
	}
	
	protected def variableExists(String name) {
		variableDeclarationScopes.exists[ se |
			se.value.containsDeclaration(name)
		]
	}
	
	protected def List<SimpleEntry<Declaration, PresenceCondition>> getPCListForLastDeclaration(String name) {
		val scope = variableDeclarationScopes.findLast[scope | scope.value.containsDeclaration(name)]
		if (scope != null)
			scope.value.pcList(name)
		else
			null
	}
	
//	protected def getType(TypeDeclaration type, PresenceCondition pc) {
//		var type
//	}
	
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
		} else if(#["TranslationUnit", "Declaration", "DeclaringList", "SUEDeclarationSpecifier",
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
			"PostfixIdentifierDeclarator", "PostfixingAbstractDeclarator",
			"CleanTypedefDeclarator", "CleanPostfixTypedefDeclarator", "DirectSelection", "AssemblyExpressionOpt"].contains(node.name)) {
			// no scope
		} else {
			throw new Exception("ScopingRule: possible scope : " + node.name + ".")
		}
		
		
		
		
		
		
		
		
		if (node.isTypeDeclaration) {
			val pc = node.guard
			val newTypeDeclaration = node.getTypeDeclaration(typeDeclarations, pc)
			
			typeDeclarations.put(newTypeDeclaration, pc)
			
		} else if (node.isFunctionDeclaration) {
			var declarator = node.getDescendantNode("SimpleDeclarator")
			if (declarator == null)
				declarator = node.getDescendantNode("ParameterTypedefDeclarator")
			
			throw new UnsupportedOperationException("Function Declaration")
//			functionDeclarations.newDeclaration(declarator.get(0).toString)
		}

		
		
		// VARIABLE DECLARATIONS
		
		// variable of type
		else if (
			     (node.name.equals("Declaration"))
			&&   (node.get(0) instanceof GNode)
			&&   (node.get(0) as GNode).name.equals("DeclaringList")
			&&  ((node.get(0) as GNode).get(0) instanceof Language<?>)
			&&  ((node.get(0) as GNode).get(1) instanceof GNode)
			&&  ((node.get(0) as GNode).get(1) as GNode).name.equals("SimpleDeclarator")
			&& (((node.get(0) as GNode).get(1) as GNode).get(0) instanceof Text<?>)
		) {
			
			val varName = (((node.get(0) as GNode).get(1) as GNode).get(0) as Text<?>).toString
			val varTypeName = ((node.get(0) as GNode).get(0) as Language<?>).toString
			val varPC = guard(node)
			val varType = typeDeclarations.get(varTypeName, varPC) as TypeDeclaration
			
			addVariable(new VariableDeclaration(varName, varType), varPC)
		}
		
		
		else if (
			#["Declaration", "ParameterDeclaration"].contains(node.name)
			&& (node.size > 1 || node.get(0) instanceof GNode)
			&& node.getDescendantNode("FunctionDeclarator") == null
			&& node.getDescendantNode("EnumSpecifier") == null
			&& (node.getDescendantNode("StructOrUnionSpecifier") == null
				|| node.getDescendantNode("SimpleDeclarator") != null)
			&& (node.getDescendantNode("TypedefTypeSpecifier") == null
				|| node.getDescendantNode("SimpleDeclarator") != null)
			&& !(node.name.equals("ParameterDeclaration")
				&& node.getDescendantNode("SimpleDeclarator") == null)
			&& !node.containsTypedef
			&& node.getDescendantNode("SUETypeSpecifier") == null
		) {
			var declarator = node.getDescendantNode("SimpleDeclarator")
			if (declarator == null)
				declarator = node.getDescendantNode("ParameterTypedefDeclarator")
			if (declarator == null) {
				throw new Exception("ScopingRule: unknown declarator.")
			}
			
			val variableName = declarator.get(0).toString
			if (!variableName.equals(Settings::reconfiguratorIncludePlaceholder)) {
				throw new UnsupportedOperationException("Add Variable Declaration")
//				addVariable(variableName)
			}
		} else if (
			#["FunctionDefinition", "FunctionDeclarator"].contains(node.name)
		) {
			var declarator = node.getDescendantNode("SimpleDeclarator")
			val functionName = declarator.get(0).toString
			throw new UnsupportedOperationException("Function Declaration")
//			functionDeclarations.newDeclaration(functionName)
		} else if (
			node.isStructDeclarationWithVariability
		) {
			
			println
			
			println('''before «typeDeclarations.size»''')
			println(typeDeclarations.names)
			
			println("found isStructDeclarationWithVariability")
			println(node.printCode)
			println(node.printAST)

			println('''after «typeDeclarations.size»''')
			
			throw new Exception
			
		} else if (#["TranslationUnit", "ExternalDeclarationList", "DeclaringList",
			"SUEDeclarationSpecifier", "DeclarationQualifierList", "StructOrUnionSpecifier",
			"StructOrUnion", "IdentifierOrTypedefName", "SimpleDeclarator", "ArrayDeclarator",
			"ArrayAbstractDeclarator", "InitializerOpt", "Initializer", "StringLiteralList",
			"Conditional", "BasicDeclarationSpecifier", "SignedKeyword", "ParameterTypedefDeclarator",
			"DeclarationExtension", "DeclarationQualifier", "TypeQualifier", "AttributeSpecifier",
			"AttributeKeyword", "AttributeListOpt", "AttributeList", "Word",
			"TypedefDeclarationSpecifier", "FunctionPrototype", "FunctionSpecifier",
			"PostfixingFunctionDeclarator", "ParameterTypeListOpt",
			"ParameterTypeList", "ParameterList", "BasicTypeSpecifier", "TypeQualifierList",
			"TypeQualifier", "ConstQualifier", "CompoundStatement", "DeclarationOrStatementList",
			"ReturnStatement", "MultiplicativeExpression", "CastExpression", "TypeName",
			"TypedefTypeSpecifier", "PrimaryIdentifier", "SelectionStatement",
			"RelationalExpression", "ExpressionStatement", "AssignmentExpression", "AssignmentOperator",
			"FunctionCall", "ExpressionList", "PrimaryExpression", "ConditionalExpression",
			"LogicalAndExpression", "UnaryExpression", "Unaryoperator", "ShiftExpression",
			"UnaryIdentifierDeclarator", "AttributeSpecifierListOpt", "AttributeSpecifierList",
			"AttributeExpressionOpt", "AbstractDeclarator", "UnaryAbstractDeclarator",
			"EqualityExpression", "LogicalORExpression", "RestrictQualifier", "AndExpression",
			"InclusiveOrExpression", "IterationStatement", "AdditiveExpression", "StatementAsExpression",
			"Subscript", "Decrement", "GotoStatement", "BreakStatement", "LabeledStatement", "Increment",
			"MatchedInitializerList", "DesignatedInitializer", "Designation", "DesignatorList",
			"Designator", "ContinueStatement", "Expression", "SUETypeSpecifier",
			"StructDeclarationList", "StructDeclaration", "StructDeclaringList", "StructDeclarator",
			"IndirectSelection", "EmptyDefinition", "EnumSpecifier", "EnumeratorList",
			"Enumerator", "EnumeratorValueOpt", "PostfixIdentifierDeclarator", "PostfixingAbstractDeclarator",
			"CleanTypedefDeclarator", "CleanPostfixTypedefDeclarator", "DirectSelection", "AssemblyExpressionOpt"].contains(node.name)
			|| (node.name.equals("ParameterDeclaration") && (node.size == 1 || !(node instanceof GNode)))
			|| (node.name.equals("ParameterDeclaration") && node.getDescendantNode("EnumSpecifier") != null )
			|| (node.name.equals("Declaration") && node.getDescendantNode("EnumSpecifier") != null )
			|| (node.name.equals("Declaration") && node.getDescendantNode("StructOrUnionSpecifier") != null )
			|| (node.name.equals("ParameterDeclaration") && node.getDescendantNode("SimpleDeclarator") == null)
		) {
			// no declaration
		} else {
			println
			println(node.printAST)
			throw new Exception("ScopingRule: possible declaration : " + node.name + ".")
		}
		
		node
	}
	
}
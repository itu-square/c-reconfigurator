package dk.itu.models.rules

import dk.itu.models.DeclarationPCMap
import dk.itu.models.Settings
import java.util.AbstractMap.SimpleEntry
import java.util.ArrayList
import java.util.List
import xtc.lang.cpp.CTag
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.tree.GNode
import xtc.util.Pair

import static extension dk.itu.models.Extensions.*

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
	
	protected def addVariable(String name) {
		variableDeclarationScopes.last.value.newDeclaration(name)
	}
	
	protected def variableExists(String name) {
		variableDeclarationScopes.exists[ se |
			se.value.containsDeclaration(name)
		]
	}
	
	protected def List<PresenceCondition> getPCListForLastDeclaration(String name) {
		val scope = variableDeclarationScopes.findLast[scope | scope.value.containsDeclaration(name)]
		if (scope != null)
			scope.value.pcList(name)
		else
			null
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
			"CleanTypedefDeclarator", "CleanPostfixTypedefDeclarator", "DirectSelection"].contains(node.name)) {
			// no scope
		} else {
			debugln
			ancestors.forEach[debugln("- " + it.name)]
			debugln(node.printAST)
			throw new Exception("ScopingRule: possible scope : " + node.name + ".")
		}
		
		
		
		
		
		
		
		
		if (
			node.name.equals("Declaration")
			&& node.containsTypedef
		) {
			var declarator = node.getDescendantNode("SimpleDeclarator")
			if (declarator == null)
				declarator = node.getDescendantNode("ParameterTypedefDeclarator")
			
			typeDeclarations.newDeclaration(declarator.get(0).toString)
		} else if (
			node.name.equals("Declaration")
			&& node.getDescendantNode("FunctionDeclarator") != null
		) {
			var declarator = node.getDescendantNode("SimpleDeclarator")
			if (declarator == null)
				declarator = node.getDescendantNode("ParameterTypedefDeclarator")
			
			functionDeclarations.newDeclaration(declarator.get(0).toString)
		} else if (
			#["Declaration", "ParameterDeclaration"].contains(node.name)
			&& (node.size > 1 || node.get(0) instanceof GNode)
			&& node.getDescendantNode("FunctionDeclarator") == null
			&& node.getDescendantNode("EnumSpecifier") == null
			&& (node.getDescendantNode("StructOrUnionSpecifier") == null
				|| node.getDescendantNode("SimpleDeclarator") != null)
			&& (node.getDescendantNode("TypedefTypeSpecifier") == null
				|| node.getDescendantNode("SimpleDeclarator") != null)
			&& !node.containsTypedef
		) {
			var declarator = node.getDescendantNode("SimpleDeclarator")
			if (declarator == null)
				declarator = node.getDescendantNode("ParameterTypedefDeclarator")
			if (declarator == null) {
				debugln(node.printAST)
				throw new Exception("ScopingRule: unknown declarator.")
			}
			
			val variableName = declarator.get(0).toString
			if (!variableName.equals(Settings::reconfiguratorIncludePlaceholder))
				addVariable(variableName)
		} else if (
			#["FunctionDefinition", "FunctionDeclarator"].contains(node.name)
		) {
			var declarator = node.getDescendantNode("SimpleDeclarator")
			val functionName = declarator.get(0).toString
			functionDeclarations.newDeclaration(functionName)
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
			"CleanTypedefDeclarator", "CleanPostfixTypedefDeclarator", "DirectSelection"].contains(node.name)
			|| (node.name.equals("ParameterDeclaration") && (node.size == 1 || !(node instanceof GNode)))
			|| (node.name.equals("ParameterDeclaration") && node.getDescendantNode("EnumSpecifier") != null )
			|| (node.name.equals("Declaration") && node.getDescendantNode("EnumSpecifier") != null )
			|| (node.name.equals("Declaration") && node.getDescendantNode("StructOrUnionSpecifier") != null )
		) {
			// no declaration
		} else {
			debugln
			debugln(node.printAST)
			throw new Exception("ScopingRule: possible declaration : " + node.name + ".")
		}
		
		node
	}
	
}
package dk.itu.models.rules

import dk.itu.models.PresenceConditionIdMap
import dk.itu.models.rules.phase3variables.RewriteVariableUseRule
import dk.itu.models.strategies.TopDownStrategy
import xtc.lang.cpp.CTag
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.tree.GNode
import xtc.tree.Node
import xtc.util.Pair

import static extension dk.itu.models.Extensions.*

class ReconfigureDeclarationRule extends ScopingRule {
	
	private val PresenceConditionIdMap pcidmap
	
	new () {
		this.pcidmap = new PresenceConditionIdMap
	}
	
	override dispatch PresenceCondition transform(PresenceCondition cond) {
		cond
	}

	override dispatch Language<CTag> transform(Language<CTag> lang) {
		lang
	}

	override dispatch Pair<Object> transform(Pair<Object> pair) {
		pair
	}
	
	override dispatch Object transform(GNode node) {
		// Update the variable scopes and declarations.
		(this as ScopingRule).transform(node)
		
		if (
			// declarations without variability
			ancestors.size >= 1
			&& #["ExternalDeclarationList", "DeclarationExtension", "DeclarationOrStatementList"].contains(ancestors.last.name)
			&& #["Declaration", "DeclarationExtension"].contains(node.name) ) {
				// TODO: rewrite variable names and function calls
				node.rewriteVariableUse(variableDeclarationScopes, node.presenceCondition, pcidmap)
		} else if (
			// type declarations with variability
			ancestors.size >= 1
			&& ancestors.last.name.equals("ExternalDeclarationList")
			&& node.name.equals("Conditional")
			&& node.get(1) instanceof GNode
			&& #["Declaration", "DeclarationExtension"].contains((node.get(1) as GNode).name)
			&& (node.get(1) as GNode).containsTypedef
			&& !(node.get(1) as GNode).containsConditional ) {
				val pc = node.get(0) as PresenceCondition
				var declarator = node.getDescendantNode("SimpleDeclarator")
				if (declarator == null)
					declarator = node.getDescendantNode("ParameterTypedefDeclarator")
				val id = declarator.get(0).toString
				typeDeclarations.putPC(id, pc)
				
				val newId = id + "_V" + pcidmap.getId(pc)
				var newNode = (node.get(1) as GNode).replaceDeclaratorTextWithNewId(newId)
				newNode.setProperty("OriginalPC", node.presenceCondition.and(pc))
				newNode
		} else if (
			// variable declarations with variability
			ancestors.size >= 1
			&& #["ExternalDeclarationList", "DeclarationOrStatementList"].contains(ancestors.last.name)
			&& node.name.equals("Conditional")
			&& node.get(1) instanceof GNode
			&& #["Declaration", "DeclarationExtension"].contains((node.get(1) as GNode).name)
			&& !(node.get(1) as GNode).containsTypedef ) {
//			&& !(node.get(1) as GNode).containsConditional
				val pc = node.get(0) as PresenceCondition
				var declarator = node.getDescendantNode("SimpleDeclarator")
				if (declarator == null)
					declarator = node.getDescendantNode("ParameterTypedefDeclarator")
				val id = declarator.get(0).toString
				
				variableDeclarationScopes.last.value.putPC(id, pc)
				
				val newId = id + "_V" + pcidmap.getId(pc)
				var newNode = (node.get(1) as GNode).replaceDeclaratorTextWithNewId(newId)
				newNode = newNode.rewriteVariableUse(variableDeclarationScopes, node.presenceCondition.and(pc), pcidmap)
				newNode = newNode.rewriteFunctionCall(functionDeclarations, node.presenceCondition.and(pc), pcidmap)
				newNode.setProperty("OriginalPC", node.presenceCondition.and(pc))
				newNode
		} else if (
			// function definition with variability
			ancestors.size >= 1
			&& ancestors.last.name.equals("ExternalDeclarationList")
			&& node.name.equals("Conditional")
			&& node.get(1) instanceof GNode
			&& (node.get(1) as GNode).name.equals("FunctionDefinition") ) {
				val pc = node.get(0) as PresenceCondition
				var declarator = node.getDescendantNode("SimpleDeclarator")
				val functionName = declarator.get(0).toString
				functionDeclarations.putPC(functionName, pc)
				
				val newName = functionName + "_V" + pcidmap.getId(pc)
				var newNode = (node.get(1) as GNode).renameFunctionWithNewId(newName)
				newNode = newNode.rewriteVariableUse(variableDeclarationScopes, node.presenceCondition.and(pc), pcidmap)
				newNode = newNode.rewriteFunctionCall(functionDeclarations, node.presenceCondition.and(pc), pcidmap)
				newNode.setProperty("OriginalPC", node.presenceCondition.and(pc))
				
				newNode
		} else if (
			// function definition without variability
			node.name.equals("FunctionDefinition") &&
			!ancestors.last.name.equals("Conditional") ) {
				node.rewriteFunctionCall(functionDeclarations, node.presenceCondition, pcidmap)
		} else if(
			// other places to rewrite variable names and function calls
			#["ExpressionStatement", "Initializer", "ReturnStatement"]
			.contains(node.name) ) {
				val tdn = new TopDownStrategy
				tdn.register(new RewriteVariableUseRule(variableDeclarationScopes, node.presenceCondition, pcidmap))
				val newNode = tdn.transform(node) as GNode
		
				return newNode
		} else if (
			// other places to rewrite variable names and function calls
			node.name.equals("SelectionStatement") ) {
				val tdn = new TopDownStrategy
				tdn.register(new RewriteVariableUseRule(variableDeclarationScopes, node.presenceCondition, pcidmap))
				val newNode = tdn.transform(node.get(2)) as Node
				
				if (!newNode.printAST.equals(node.get(2).printAST))
					return GNode::createFromPair(
						"SelectionStatement",
						node.map[
							if (node.indexOf(it) == 2) newNode
							else it].toPair)
					else return node
		} else if (
			// the rest
			#["TranslationUnit", "ExternalDeclarationList", "DeclaringList",
				"SUEDeclarationSpecifier", "DeclarationQualifierList", "StructOrUnionSpecifier",
				"StructOrUnion", "IdentifierOrTypedefName", "SimpleDeclarator", "ArrayDeclarator",
				"ArrayAbstractDeclarator", "InitializerOpt", "Initializer", "StringLiteralList",
				"BasicDeclarationSpecifier", "SignedKeyword", "ParameterTypedefDeclarator",
				"DeclarationQualifier", "TypeQualifier", "AttributeSpecifier", "AttributeKeyword",
				"AttributeListOpt", "AttributeList", "Word", "TypedefDeclarationSpecifier",
				"FunctionPrototype", "FunctionSpecifier", "FunctionDeclarator",
				"PostfixingFunctionDeclarator", "ParameterTypeListOpt", "ParameterTypeList",
				"ParameterList", "ParameterDeclaration", "BasicTypeSpecifier", "TypeQualifierList",
				"TypeQualifier", "ConstQualifier", "CompoundStatement", "DeclarationOrStatementList",
				"ReturnStatement", "MultiplicativeExpression", "CastExpression", "TypeName",
				"TypedefTypeSpecifier", "PrimaryIdentifier", "RelationalExpression",
				"ExpressionStatement", "AssignmentExpression", "AssignmentOperator", "FunctionCall",
				"ExpressionList", "PrimaryExpression", "ConditionalExpression", "LogicalAndExpression",
				"UnaryExpression", "Unaryoperator", "ShiftExpression", "Conditional",
				"UnaryIdentifierDeclarator", "AttributeSpecifierListOpt", "AttributeSpecifierList",
				"AttributeExpressionOpt", "AbstractDeclarator", "UnaryAbstractDeclarator",
				"EqualityExpression", "LogicalORExpression", "RestrictQualifier", "AndExpression",
				"InclusiveOrExpression", "IterationStatement", "AdditiveExpression", "StatementAsExpression",
				"Subscript", "Decrement", "GotoStatement", "BreakStatement", "LabeledStatement", "Increment",
				"MatchedInitializerList", "DesignatedInitializer", "Designation", "DesignatorList",
				"Designator", "ContinueStatement", "Expression", "SUETypeSpecifier",
				"StructDeclarationList", "StructDeclaration", "StructDeclaringList", "StructDeclarator",
				"IndirectSelection", "EmptyDefinition", "EnumSpecifier", "EnumeratorList", "Enumerator",
				"EnumeratorValueOpt", "PostfixIdentifierDeclarator", "PostfixingAbstractDeclarator",
				"CleanTypedefDeclarator", "CleanPostfixTypedefDeclarator", "DirectSelection"].contains(node.name)) {
			node
		} else {
			debugln
			debugln('''------------------------------''')
			debugln('''- ReconfigureDeclarationRule -''')
			debugln('''------''')
			ancestors.forEach[
				debugln('''- «it.name»''')]
			debugln((node as GNode).printAST)
			debugln
			throw new Exception("ReconfigureDeclarationRule: unknown declaration : " + node.name + ".")
		}
	}
}
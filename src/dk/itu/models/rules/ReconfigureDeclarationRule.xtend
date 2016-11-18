package dk.itu.models.rules

import dk.itu.models.PresenceConditionIdMap
import xtc.lang.cpp.CTag
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.tree.GNode
import xtc.util.Pair

import static extension dk.itu.models.Extensions.*
import static extension dk.itu.models.Patterns.*
import dk.itu.models.utils.TypeDeclaration
import dk.itu.models.utils.VariableDeclaration

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
			&& #["Declaration", "DeclarationExtension"].contains(node.name)
		) {
			node.rewriteVariableUse(variableDeclarationScopes, node.presenceCondition, pcidmap)
		} else
//		if (
//			node.isTypeDeclarationWithVariability
//		) {
//			// get current PC and names
//			val pc = node.guard.and((node.get(0) as PresenceCondition))
//			val name = (node.get(1) as GNode).getNameOfTypeDeclaration
//			val type = (node.get(1) as GNode).getTypeOfTypeDeclaration
//			
//			// get registered type declaration
//			if (!typeDeclarations.containsDeclaration(type))
//				throw new Exception('''ReconfigureDeclarationRule: type declaration «type» not found.''')
//			val typeDeclaration = typeDeclarations.get(type, pc) as TypeDeclaration
//			
//			// create new name and new type declaration
//			val variantName = name + "_V" + pcidmap.getId(pc)
//			val variantTypeDeclaration = new TypeDeclaration(variantName, typeDeclaration)
//			this.typeDeclarations.put(name, variantTypeDeclaration, pc)
//			
//			// rewrite the names and return the node
//			var newNode = (node.get(1) as GNode).replaceDeclaratorTextWithNewId(variantName)
//			newNode.setProperty("OriginalPC", node.presenceCondition.and(pc))
//			newNode
//		} else
		if (
			node.isVariableDeclarationWithVariability
		) {
			val varPC = node.get(0) as PresenceCondition
			val varDeclarationNode = node.get(1) as GNode
			val varName = varDeclarationNode.getNameOfVariableDeclaration
			val varType = varDeclarationNode.getTypeOfVariableDeclaration
			
			// get registered type declaration
			if (!typeDeclarations.containsDeclaration(varType))
				throw new Exception('''ReconfigureDeclarationRule: type declaration «varType» not found.''')
			
			val typeDeclarationList = typeDeclarations.declarationList(varType)
			
			if (typeDeclarationList.size == 1) {
				val typeDeclaration = typeDeclarationList.get(0).key as TypeDeclaration

				val newName = varName + "_V" + pcidmap.getId(varPC)
				val varDeclaration = new VariableDeclaration(newName, typeDeclaration)
				addVariable(varName, varDeclaration, varPC)

				var newNode = (node.get(1) as GNode).replaceDeclaratorTextWithNewId(newName)
				newNode = newNode.rewriteVariableUse(variableDeclarationScopes, node.presenceCondition.and(varPC), pcidmap)
				newNode = newNode.rewriteFunctionCall(functionDeclarations, node.presenceCondition.and(varPC), pcidmap)
				newNode.setProperty("OriginalPC", node.presenceCondition.and(varPC))
				return newNode
			} else {
				throw new Exception("ReconfigureDeclarationRule: not handled: multiple type declarations.")
			}
		} else
//		if (
//			// function definition with variability
//			ancestors.size >= 1
//			&& ancestors.last.name.equals("ExternalDeclarationList")
//			&& node.name.equals("Conditional")
//			&& node.get(1) instanceof GNode
//			&& (node.get(1) as GNode).name.equals("FunctionDefinition") ) {
//				val pc = node.get(0) as PresenceCondition
//				var declarator = node.getDescendantNode("SimpleDeclarator")
//				val functionName = declarator.get(0).toString
//				if(true) throw new UnsupportedOperationException("putPC")
////				functionDeclarations.putPC(functionName, pc)
//				
//				val newName = functionName + "_V" + pcidmap.getId(pc)
//				var newNode = (node.get(1) as GNode).renameFunctionWithNewId(newName)
//				newNode = newNode.rewriteVariableUse(variableDeclarationScopes, node.presenceCondition.and(pc), pcidmap)
//				newNode = newNode.rewriteFunctionCall(functionDeclarations, node.presenceCondition.and(pc), pcidmap)
//				newNode.setProperty("OriginalPC", node.presenceCondition.and(pc))
//				
//				newNode
//		} else
		if (
			node.isFunctionDefinition
			&& !ancestors.last.name.equals("Conditional")
		) {
			node.rewriteFunctionCall(functionDeclarations, node.presenceCondition, pcidmap)
		} else
//		if(
//			// other places to rewrite variable names and function calls
//			#["ExpressionStatement", "Initializer", "ReturnStatement"]
//			.contains(node.name) ) {
//				val tdn = new TopDownStrategy
//				tdn.register(new RewriteVariableUseRule(variableDeclarationScopes, node.presenceCondition, pcidmap))
//				val newNode = tdn.transform(node) as GNode
//		
//				return newNode
//		} else if (
//			// other places to rewrite variable names and function calls
//			node.name.equals("SelectionStatement") ) {
//				val tdn = new TopDownStrategy
//				tdn.register(new RewriteVariableUseRule(variableDeclarationScopes, node.presenceCondition, pcidmap))
//				val newNode = tdn.transform(node.get(2)) as Node
//				
//				if (!newNode.printAST.equals(node.get(2).printAST))
//					return GNode::createFromPair(
//						"SelectionStatement",
//						node.map[
//							if (node.indexOf(it) == 2) newNode
//							else it].toPair)
//					else return node
//		} else
		if (
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
				"CleanTypedefDeclarator", "CleanPostfixTypedefDeclarator", "DirectSelection",
				"AssemblyExpressionOpt", "LocalLabelDeclarationListOpt",
				"ParameterIdentifierDeclaration"].contains(node.name)
			|| (node.name.equals("ParameterAbstractDeclaration") && node.size == 1)
		) {
			node
		} else {
			println
			println('''------------------------------''')
			println('''- ReconfigureDeclarationRule -''')
			println('''------------------------------''')
			ancestors.forEach[
				println('''- «it.name»''')]
			println((node as GNode).printAST)
			println
			throw new Exception("ReconfigureDeclarationRule: unknown declaration : " + node.name + ".")
		}
	}
}
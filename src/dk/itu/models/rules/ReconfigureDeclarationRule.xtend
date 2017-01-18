package dk.itu.models.rules

import dk.itu.models.PresenceConditionIdMap
import dk.itu.models.utils.FunctionDeclaration
import dk.itu.models.utils.TypeDeclaration
import dk.itu.models.utils.VariableDeclaration
import xtc.lang.cpp.CTag
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.tree.GNode
import xtc.util.Pair

import static extension dk.itu.models.Extensions.*
import static extension dk.itu.models.Patterns.*

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
			node.isStructDeclarationWithVariability
		) {
			val pc = node.get(0) as PresenceCondition
			val declarationNode = node.get(1) as GNode
			val name = declarationNode.getNameOfStructDeclaration.replace("struct ", "")
			
			val type = declarationNode.getNameOfStructDeclaration
			
			// get registered type declaration
			if (!typeDeclarations.containsDeclaration(type)) {
				var typeDeclaration = new TypeDeclaration(type, null)
				typeDeclarations.put(type, typeDeclaration, pc)
				
				typeDeclaration = new TypeDeclaration(type + "*", null)
				typeDeclarations.put(type + "*", typeDeclaration, pc)
				
				typeDeclaration = new TypeDeclaration(type + "**", null)
				typeDeclarations.put(type + "**", typeDeclaration, pc)
			}
			
			val typeDeclarationList = typeDeclarations.declarationList(type)
			
			if (typeDeclarationList.size == 1) {
				val typeDeclaration = typeDeclarationList.get(0).key as TypeDeclaration

				val newName = name + "_V" + pcidmap.getId(pc)
				val newType = type.replace(name, newName)
				
				val newTypeDeclaration = new TypeDeclaration(newType, typeDeclaration)
				typeDeclarations.put(newType, newTypeDeclaration, pc)
				
				var newNode = declarationNode.replaceIdentifierVarName(name, newName)
				newNode.setProperty("OriginalPC", node.presenceCondition.and(pc))
				return newNode
			} else {
				throw new Exception("ReconfigureDeclarationRule: not handled: multiple type declarations.")
			}
		} else
		
		if (
			node.isFunctionDeclarationWithVariability
			&& (node.get(1) as GNode).isFunctionDeclarationWithSignatureVariability
		) {
			val pc = node.get(0) as PresenceCondition
			val declarationNode = node.get(1) as GNode
			val name = declarationNode.getNameOfFunctionDeclaration
			val type = declarationNode.getTypeOfFunctionDeclaration
			
			println
			println ("isFunctionDeclarationWithSignatureVariability")
			println ("-------------")
			println (node.printCode)
			println ("-------------")
			println ('''fpc   [«pc»]''')
			println ('''fname [«name»]''')
			println ('''ftype [«type»]''')
			val params = node.getDescendantNode("ParameterList").filter[(it instanceof GNode) && (it as GNode).isParameterDeclaration]
			println ('''params [«params.size»]''')
			params.forEach[println(''' - [«(it as GNode).getTypeOfParameterDeclaration»] of [«(it as GNode).getNameOfParameterDeclaration»]''')]
			
			println ("=============")
			
			return node
		} else
		
		if (
			node.isFunctionDeclarationWithVariability
		) {
			val pc = node.get(0) as PresenceCondition
			val declarationNode = node.get(1) as GNode
			val name = declarationNode.getNameOfFunctionDeclaration
			val type = declarationNode.getTypeOfFunctionDeclaration
			
	
			// get registered type declaration
			if (!typeDeclarations.containsDeclaration(type))
				throw new Exception('''ReconfigureDeclarationRule: type declaration «type» not found.''')
			
			val typeDeclarationList = typeDeclarations.declarationList(type)
			
			if (typeDeclarationList.size == 1) {
				val typeDeclaration = typeDeclarationList.get(0).key as TypeDeclaration

				val newName = name + "_V" + pcidmap.getId(pc)
				val funcDeclaration = new FunctionDeclaration(newName, typeDeclaration)
				functionDeclarations.put(newName, funcDeclaration, pc)

				var newNode = declarationNode.replaceIdentifierVarName(name, newName)
				newNode.setProperty("OriginalPC", node.presenceCondition.and(pc))
				return newNode
			} else {
				throw new Exception("ReconfigureDeclarationRule: not handled: multiple type declarations.")
			}
		} else
		
		
		
		if (
			node.isFunctionDefinitionWithVariability
		) {
			debug("isFunctionDefinitionWithVariability", true)
			val funcPC = node.get(0) as PresenceCondition
			val funcDefinitionNode = node.get(1) as GNode
			val funcName = funcDefinitionNode.getNameOfFunctionDefinition
			val funcType = funcDefinitionNode.getTypeOfFunctionDefinition
			debug('''  --- [«funcName»] of [«funcType»]''')
			
			// get registered type declaration
			if (!typeDeclarations.containsDeclaration(funcType))
				throw new Exception('''ReconfigureDeclarationRule: type declaration «funcType» not found.''')
			
			val typeDeclarationList = typeDeclarations.declarationList(funcType)
			
			if (typeDeclarationList.size == 1) {
				val typeDeclaration = typeDeclarationList.get(0).key as TypeDeclaration

				val newName = funcName + "_V" + pcidmap.getId(funcPC)
				val funcDeclaration = new FunctionDeclaration(newName, typeDeclaration)
				functionDeclarations.put(funcName, funcDeclaration, funcPC)
				
				var newNode = funcDefinitionNode.renameFunctionWithNewId(newName)
				newNode = newNode.rewriteVariableUse(variableDeclarationScopes, node.presenceCondition.and(funcPC), pcidmap)
				newNode = newNode.rewriteFunctionCall(functionDeclarations, node.presenceCondition.and(funcPC), pcidmap)
				newNode.setProperty("OriginalPC", node.presenceCondition.and(funcPC))
				return newNode
			} else {
				throw new Exception("ReconfigureDeclarationRule: not handled: multiple type declarations.")
			}
		} else
		
		if (
			node.isFunctionDefinition
			&& !ancestors.last.name.equals("Conditional")
		) {
			debug("   isFunctionDefinition", true)
			val funcName = node.nameOfFunctionDefinition
			debug("   - " + funcName)
			functionDeclarations.rem(funcName, funcName)
			
			var newpair = Pair.EMPTY
			for (Object child : node.toList) {
				if ((
						(child instanceof GNode)
						&& (child as GNode).name.equals("FunctionPrototype")
					) || (
						(child instanceof Language<?>)
				)) {
					newpair = newpair.add(child)
				} else {
					val nodepc = node.presenceCondition
					var newnode = (child as GNode).rewriteVariableUse(variableDeclarationScopes, nodepc, pcidmap)
					newnode = (child as GNode).rewriteFunctionCall(functionDeclarations, nodepc, pcidmap)
					newpair = newpair.add(newnode)
				}
			}
			return GNode.createFromPair(
				"FunctionDefinition",
				newpair,
				if (node.properties == null)
					null
				else
					node.properties.toInvertedMap[p | node.getProperty(p.toString)]
				)
		} else

		if (
			node.isVariableDeclarationWithVariability
		) {
			debug("   isVariableDeclarationWithVariability", true)
			val varPC = node.get(0) as PresenceCondition
			val varDeclarationNode = node.get(1) as GNode
			val varName = varDeclarationNode.getNameOfVariableDeclaration
			val varType = varDeclarationNode.getTypeOfVariableDeclaration
			println('''   - [«varName»] of [«varType»]''')
			
			// get registered type declaration
			if (!typeDeclarations.containsDeclaration(varType))
				throw new Exception('''ReconfigureDeclarationRule: type declaration «varType» not found.''')
			
			val typeDeclarationList = typeDeclarations.declarationList(varType)
			
			if (typeDeclarationList.size == 1) {
				val typeDeclaration = typeDeclarationList.get(0).key as TypeDeclaration

				val newName = varName + "_V" + pcidmap.getId(varPC)
				val varDeclaration = new VariableDeclaration(newName, typeDeclaration)
				addVariable(varName, varDeclaration, varPC)

				var newNode = varDeclarationNode.replaceDeclaratorTextWithNewId(newName)
				newNode = newNode.rewriteVariableUse(variableDeclarationScopes, node.presenceCondition.and(varPC), pcidmap)
				newNode = newNode.rewriteFunctionCall(functionDeclarations, node.presenceCondition.and(varPC), pcidmap)
				newNode.setProperty("OriginalPC", node.presenceCondition.and(varPC))
				return newNode
			} else {
				throw new Exception("ReconfigureDeclarationRule: not handled: multiple type declarations.")
			}
		} else
		
		if (
			// other places to rewrite variable names and function calls
			node.name.equals("SelectionStatement")
		) {
			debug
			debug("   other rewrites", true)
			debug("   - " + node.name)
			val newNode = (node.get(2) as GNode).rewriteVariableUse(variableDeclarationScopes, node.presenceCondition, pcidmap)
			
			if (!newNode.printAST.equals(node.get(2).printAST)) {
				return GNode::createFromPair(
					"SelectionStatement",
					node.map[
						if (node.indexOf(it) == 2) newNode
						else it].toPair)
			} else {
				return node
			}
		} else
		
		if (
			node.name.equals("IterationStatement")
			|| node.name.equals("CompoundStatement")
			|| node.name.equals("ExpressionStatement")
		) {
			debug
			debug("   other rewrites", true)
			debug("   - " + node.name)
			return node.rewriteVariableUse(variableDeclarationScopes, node.presenceCondition, pcidmap)
		} else
		
		if (
			// declarations without variability
			ancestors.size >= 1
			&& #["ExternalDeclarationList", "DeclarationExtension", "DeclarationOrStatementList"].contains(ancestors.last.name)
			&& #["Declaration", "DeclarationExtension"].contains(node.name)
		) {
			node.rewriteVariableUse(variableDeclarationScopes, node.presenceCondition, pcidmap)
		} else
		
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
				"TypeQualifier", "ConstQualifier", "DeclarationOrStatementList",
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
				"AssemblyExpressionOpt", "LocalLabelDeclarationListOpt", "ExpressionOpt",
				"ParameterIdentifierDeclaration", "StructSpecifier", "BitFieldSizeOpt",
				"ParameterAbstractDeclaration", "VolatileQualifier", "UnionSpecifier"].contains(node.name)
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
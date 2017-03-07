package dk.itu.models.rules

import dk.itu.models.Reconfigurator
import dk.itu.models.utils.DeclarationPCPair
import dk.itu.models.utils.FunctionDeclaration
import dk.itu.models.utils.TypeDeclaration
import dk.itu.models.utils.VariableDeclaration
import java.util.ArrayList
import java.util.List
import xtc.lang.cpp.CTag
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.tree.GNode
import xtc.util.Pair

import static extension dk.itu.models.Extensions.*
import static extension dk.itu.models.Patterns.*

class ReconfigureDeclarationRule extends ScopingRule {
	
	override dispatch PresenceCondition transform(PresenceCondition cond) {
		cond
	}

	override dispatch Language<CTag> transform(Language<CTag> lang) {
		lang
	}

	override dispatch Pair<Object> transform(Pair<Object> pair) {
		if (
			!pair.empty
			&& (pair.head instanceof GNode)
			&& (pair.head as GNode).isFunctionDeclarationWithVariability
			&& ((pair.head as GNode).get(1) as GNode).isFunctionDeclarationWithSignatureVariability(typeDeclarations)
		) {
			val node = pair.head as GNode
			val pc = node.get(0) as PresenceCondition
			val declarationNode = node.get(1) as GNode
			val type = declarationNode.getTypeOfFunctionDeclaration
			
			val varType = declarationNode.getVariableSignatureTypesOfFunctionDeclaration(typeDeclarations).head
			val declarations = typeDeclarations.declarationList(varType).filterDeclarations(type, pc)
			
			var Pair<Object> newPair = Pair::EMPTY
			
			for(DeclarationPCPair declPair : declarations) {
				val newDeclarationNode = declarationNode
					.replaceIdentifierVarName(varType.replace("struct ", ""), declPair.declaration.name.replace("struct ", ""))
				newPair = newPair.add(GNode::create("Conditional", pc.and(declPair.pc), newDeclarationNode))
			}

			newPair = newPair.append(pair.tail)
			return newPair
		} else
		
		// |- #ifdef pc
		// |  |- typedef refTypeName typeName;
		// |- ... tail
		if (
			!pair.empty
			&& (pair.head instanceof GNode)
			&& (pair.head as GNode).isTypeDeclarationWithVariability
			&& ((pair.head as GNode).get(1) as GNode).isTypeDeclarationWithTypeVariability(typeDeclarations)
		) {
			val node = pair.head as GNode
			val pc = node.get(0) as PresenceCondition
			val declarationNode = node.get(1) as GNode
			val refTypeName = declarationNode.getTypeOfTypeDeclaration
			
			val filtered = typeDeclarations.declarationList(refTypeName).filterDeclarations(refTypeName, pc)
			
			var Pair<Object> newPair = Pair::EMPTY
			
			for(DeclarationPCPair declPair : filtered) {
				val newDeclarationNode = if(!refTypeName.equals(declPair.declaration.name))
						declarationNode.replaceIdentifierVarName(refTypeName, declPair.declaration.name)
					else
						declarationNode
				newDeclarationNode.setProperty("refTypeVariabilityHandled", true)
				newPair = newPair.add(GNode::create("Conditional", pc.and(declPair.pc), newDeclarationNode))
			}
			
			newPair = newPair.append(pair.tail)
			return newPair				
		}
			
		pair
	}
	
	override dispatch Object transform(GNode node) {
		// Update the variable scopes and declarations.
		(this as ScopingRule).transform(node)
		
		if (
			node.isTypeDeclarationWithVariability
		) {
			val pc = node.get(0) as PresenceCondition
			val declarationNode = node.get(1) as GNode
			val typeName = declarationNode.getNameOfTypeDeclaration
			val refTypeName = declarationNode.getTypeOfTypeDeclaration
			
			var refTypeDeclaration = typeDeclarations.getDeclaration(refTypeName) as TypeDeclaration
			if (refTypeDeclaration == null)
				throw new Exception('''ReconfigureDeclarationRule: type declaration [«refTypeName»] not found.''')
			
			var typeDeclaration = typeDeclarations.getDeclaration(typeName) as TypeDeclaration
			if (typeDeclaration == null) {
				typeDeclaration = new TypeDeclaration(typeName, refTypeDeclaration)
				typeDeclarations.put(typeDeclaration)
			}
			
			val newTypeName = typeName + "_V" + (typeDeclarations.declarationList(typeName).size + 1)
			val newTypeDeclaration = new TypeDeclaration(newTypeName, refTypeDeclaration)
			typeDeclarations.put(typeDeclaration, newTypeDeclaration, pc)
			
			var newNode = declarationNode.replaceIdentifierVarName(typeName, newTypeName)
			newNode.setProperty("OriginalPC", node.presenceCondition.and(pc))
			return newNode
		} else
		
		
		
		if (
			node.isStructTypeDeclarationWithVariability
		) {
			val pc = node.get(0) as PresenceCondition
			val declarationNode = node.get(1) as GNode
			val typeName = declarationNode.getNameOfStructTypeDeclaration
			val refTypeName = declarationNode.getTypeOfStructTypeDeclaration
			
			if (refTypeName.equals("struct")) {
				var typeDeclaration = typeDeclarations.getDeclaration(typeName) as TypeDeclaration
				if (typeDeclaration == null) {
					typeDeclaration = new TypeDeclaration(typeName, null)
					typeDeclarations.put(typeDeclaration, null, pc)
				}
				
				val newTypeName = typeName + "_V" + (typeDeclarations.declarationList(typeName).size + 1)
				val newTypeDeclaration = new TypeDeclaration(newTypeName, null)
				typeDeclarations.put(typeDeclaration, newTypeDeclaration, pc)
				
				var newNode = declarationNode.replaceIdentifierVarName(typeName, newTypeName)
				newNode.setProperty("OriginalPC", node.presenceCondition.and(pc))
				return newNode
			} else {
				throw new Exception("Case not handled")
			}
		} else
		
		
		
		if (
			node.isStructUnionDeclarationWithVariability
		) {
			val pc = node.get(0) as PresenceCondition
			val declarationNode = node.get(1) as GNode
			val type = declarationNode.getNameOfStructUnionDeclaration
			val name = type.replace("struct ", "").replace("union ", "")
			
			var typeDeclaration = typeDeclarations.getDeclaration(type)
			if (typeDeclaration === null) {
				typeDeclaration = new TypeDeclaration(type, null)
				typeDeclarations.put(typeDeclaration)
			}
			
			val newType = type + "_V" + (typeDeclarations.declarationList(type).size + 1)
			val newName = newType.replace("struct ", "").replace("union ", "")
			
			val newTypeDeclaration = new TypeDeclaration(newType, null)
			typeDeclarations.put(typeDeclaration, newTypeDeclaration, pc)
			
			var newNode = declarationNode.replaceIdentifierVarName(name, newName)
			newNode.setProperty("OriginalPC", node.presenceCondition.and(pc))
			return newNode
		} else
		
		
		
		if (
			node.isEnumDeclarationWithVariability
		) {
			val pc = node.get(0) as PresenceCondition
			var newNode = node.get(1) as GNode
			
			for (String enumerator : node.getDescendantNode("EnumeratorList").filter[(it instanceof GNode) && (it as GNode).name.equals("Enumerator")].map[(it as GNode).get(0).toString]) {
				var enumeratorDeclaration = variableDeclarations.getDeclaration(enumerator)
				if (enumeratorDeclaration == null) {
					enumeratorDeclaration = new VariableDeclaration(enumerator, typeDeclarations.getDeclaration("int") as TypeDeclaration)
					variableDeclarations.put(enumeratorDeclaration)
				}
				
				val newEnumerator = enumerator + "_V" + (variableDeclarations.declarationList(enumerator).size + 1)
				newNode = newNode.replaceIdentifierVarName(enumerator, newEnumerator)
			}
			
			newNode.setProperty("OriginalPC", node.presenceCondition.and(pc))
			return newNode
		} else
		
		
		
		if (
			node.isFunctionDeclarationWithVariability
		) {
			val pc = node.get(0) as PresenceCondition
			val declarationNode = node.get(1) as GNode
			val funcName = declarationNode.getNameOfFunctionDeclaration
			val funcType = declarationNode.getTypeOfFunctionDeclaration
			
			var funcTypeDeclaration = typeDeclarations.getDeclaration(funcType) as TypeDeclaration
			if (funcTypeDeclaration == null)
				throw new Exception('''ReconfigureDeclarationRule: type declaration [«funcType»] not found.''')
			
			var funcDeclaration = functionDeclarations.getDeclaration(funcName) as FunctionDeclaration
			if (funcDeclaration == null) {
				funcDeclaration = new FunctionDeclaration(funcName, funcTypeDeclaration)
				functionDeclarations.put(funcDeclaration)
			}
			
			val newFuncName = funcName + "_V" + (functionDeclarations.declarationList(funcName).size + 1)
			val newFuncDeclaration = new FunctionDeclaration(newFuncName, funcTypeDeclaration)
			functionDeclarations.put(funcDeclaration, newFuncDeclaration, pc)

			var newNode = declarationNode.replaceIdentifierVarName(funcName, newFuncName)
			newNode.setProperty("OriginalPC", node.presenceCondition.and(pc))
			return newNode
		} else
		
		
		
		if (
			node.isFunctionDefinitionWithVariability
		) {
			val pc = node.get(0) as PresenceCondition
			val definitionNode = node.get(1) as GNode
			val funcName = definitionNode.getNameOfFunctionDefinition
			val funcType = definitionNode.getTypeOfFunctionDefinition
			
			var funcTypeDeclaration = typeDeclarations.getDeclaration(funcType) as TypeDeclaration
			if (funcTypeDeclaration == null)
				throw new Exception('''ReconfigureDeclarationRule: type declaration «funcType» not found.''')
			
			var funcDeclaration = functionDeclarations.getDeclaration(funcName) as FunctionDeclaration
			if (funcDeclaration == null) {
				funcDeclaration = new FunctionDeclaration(funcName, funcTypeDeclaration)
				functionDeclarations.put(funcDeclaration)
			}
			
			val newFuncName = funcName + "_V" + (functionDeclarations.declarationList(funcName).size + 1)
			val newFuncDeclaration = new FunctionDeclaration(newFuncName, funcTypeDeclaration)
			functionDeclarations.put(funcDeclaration, newFuncDeclaration, pc)

			var newNode = definitionNode.renameFunctionWithNewId(newFuncName)
			newNode = newNode.rewriteVariableUse(variableDeclarations, node.presenceCondition.and(pc))
			newNode = newNode.rewriteFunctionCall(functionDeclarations, node.presenceCondition.and(pc))
			newNode.setProperty("OriginalPC", node.presenceCondition.and(pc))
			return newNode
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
					var newnode = (child as GNode).rewriteVariableUse(variableDeclarations, nodepc)
					newnode = (child as GNode).rewriteFunctionCall(functionDeclarations, nodepc)
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
			val varPC = node.get(0) as PresenceCondition
			val varDeclarationNode = node.get(1) as GNode
			val varName = varDeclarationNode.getNameOfVariableDeclaration
			val varType = varDeclarationNode.getTypeOfVariableDeclaration
			
			println
			println(node.printCode)
			println
			
			// get registered type declaration
			if (!typeDeclarations.containsDeclaration(varType))
				throw new Exception('''ReconfigureDeclarationRule: type declaration «varType» not found.''')
			
			val typeDeclarationList = typeDeclarations.declarationList(varType)
			
			if (typeDeclarationList.size == 1) {
				val typeDeclaration = typeDeclarationList.get(0).declaration as TypeDeclaration

				val newName = varName + "_V?"// + pcidmap.getId(varPC)
				val varDeclaration = new VariableDeclaration(newName, typeDeclaration)
				variableDeclarations.put(varDeclaration)

				var newNode = varDeclarationNode.replaceDeclaratorTextWithNewId(newName)
				newNode = newNode.rewriteVariableUse(variableDeclarations, node.presenceCondition.and(varPC))
				newNode = newNode.rewriteFunctionCall(functionDeclarations, node.presenceCondition.and(varPC))
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
			val newNode = (node.get(2) as GNode).rewriteVariableUse(variableDeclarations, node.presenceCondition)
			
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
			return node.rewriteVariableUse(variableDeclarations, node.presenceCondition)
		} else
		
		if (
			// declarations without variability
			ancestors.size >= 1
			&& #["ExternalDeclarationList", "DeclarationExtension", "DeclarationOrStatementList"].contains(ancestors.last.name)
			&& #["Declaration", "DeclarationExtension"].contains(node.name)
		) {
			node.rewriteVariableUse(variableDeclarations, node.presenceCondition)
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
				"ParameterAbstractDeclaration", "VolatileQualifier", "UnionSpecifier", "AssemblyStatement",
				"AsmKeyword", "Assemblyargument", "AssemblyoperandsOpt", "Assemblyclobbers", "AssemblyExpression"
				].contains(node.name)
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
	
	
	
	private def filterDeclarations(List<DeclarationPCPair> inDeclarations, String typeName, PresenceCondition guardPC) {
		
		val declarations = new ArrayList<DeclarationPCPair>
		
		var disjunctionPC = Reconfigurator::presenceConditionManager.newPresenceCondition(false)
		for (DeclarationPCPair pair : inDeclarations) {
			val pc = pair.pc
			if (!guardPC.and(pc).isFalse) {
				declarations.add(pair)
				disjunctionPC = pc.or(disjunctionPC)
			}
		}
		
		if (!guardPC.BDD.imp(disjunctionPC.BDD).isOne) {
			declarations.add(new DeclarationPCPair(
				new TypeDeclaration(typeName, null),
				disjunctionPC.not
			))
		}
		
		return declarations
	}
}
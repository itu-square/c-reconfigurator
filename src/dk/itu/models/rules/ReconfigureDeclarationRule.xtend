package dk.itu.models.rules

import dk.itu.models.PresenceConditionIdMap
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
				typeDeclaration = new TypeDeclaration(typeName, null)
			}
			
			val newTypeName = typeName + "_V" + pcidmap.getId(pc)
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
				
				val newTypeName = typeName + "_V" + pcidmap.getId(pc)
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
			node.isStructDeclarationWithVariability
		) {
			val pc = node.get(0) as PresenceCondition
			val declarationNode = node.get(1) as GNode
			val type = declarationNode.getNameOfStructDeclaration
			val name = type.replace("struct ", "")
			
			var TypeDeclaration typeDeclaration
			
			if (!typeDeclarations.containsDeclaration(type)) {
				typeDeclaration = new TypeDeclaration(type, null)
				typeDeclarations.put(typeDeclaration, null, pc)
			}
			
			val newName = name + "_V" + pcidmap.getId(pc)
			val newType = type.replace(name, newName)
			
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
				val newEnumerator = enumerator + "_V" + pcidmap.getId(pc)
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
			val typeName = declarationNode.getTypeOfFunctionDeclaration
			
			var typeDeclaration = typeDeclarations.getDeclaration(typeName) as TypeDeclaration
			
			// get registered type declaration
			if (typeDeclaration == null)
				throw new Exception('''ReconfigureDeclarationRule: type declaration [«typeName»] not found.''')
			
			val newFuncName = funcName + "_V" + pcidmap.getId(pc)
			val funcDeclaration = new FunctionDeclaration(newFuncName, typeDeclaration)

			functionDeclarations.put(funcDeclaration, null, pc)

			var newNode = declarationNode.replaceIdentifierVarName(funcName, newFuncName)
			newNode.setProperty("OriginalPC", node.presenceCondition.and(pc))
			return newNode
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
				val typeDeclaration = typeDeclarationList.get(0).declaration as TypeDeclaration

				val newName = funcName + "_V" + pcidmap.getId(funcPC)
				val funcDeclaration = new FunctionDeclaration(newName, typeDeclaration)
				functionDeclarations.put(funcDeclaration, null, funcPC)
				
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
			
			// get registered type declaration
			if (!typeDeclarations.containsDeclaration(varType))
				throw new Exception('''ReconfigureDeclarationRule: type declaration «varType» not found.''')
			
			val typeDeclarationList = typeDeclarations.declarationList(varType)
			
			if (typeDeclarationList.size == 1) {
				val typeDeclaration = typeDeclarationList.get(0).declaration as TypeDeclaration

				val newName = varName + "_V" + pcidmap.getId(varPC)
				val varDeclaration = new VariableDeclaration(newName, typeDeclaration)
				addVariable(varDeclaration, null, varPC)

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
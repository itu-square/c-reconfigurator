package itu

import xtc.tree.GNode
import xtc.tree.Node
import xtc.lang.cpp.Syntax.Language
import xtc.lang.cpp.PresenceConditionManager
import java.util.List

class TxPrintCode implements Tx {
	
	private var indent = ""
	
	override tx_start(PresenceConditionManager.PresenceCondition condition, List<Node> ancestors) {
		if(ancestors.last.head == condition)
			println('''«indent»#if «condition»''')
		else
			println('''«indent»#elif «condition»''')
	}

	override tx_end(PresenceConditionManager.PresenceCondition condition, List<Node> ancestors) {
		
	}

	override tx_start(Language language, List<Node> ancestors) {
		switch (language.toString) {
			case ";":
				println(language)
			case "{":
				{ println(language); indent += "  " }
			case "}":
				{ indent = indent.substring(2); println(language) }
			case "return": {
				print(language)
				if (ancestors.last.length > 2) print(" ")
			}
			default: print(language)
		}
	}

	override tx_end(Language language, List<Node> ancestors) {
	}

	override tx_start(GNode node, List<Node> ancestors) {
		switch(node.name) {
			case "TranslationUnit": print("")
			case "ExternalDeclarationList": print("")
			case "Conditional": print("")
			case "Declaration":
				print(indent)
			case "DeclaringList": print("")
			case "FunctionDeclarator": print("")
			case "SimpleDeclarator":
				print(" ")
			case "PostfixingFunctionDeclarator": print("")
			case "FunctionDefinition": print("")
			case "FunctionPrototype": print("")
			case "CompoundStatement": print("")
			case "DeclarationOrStatementList": print("")
			case "InitializerOpt":
				print(" ")
			case "Initializer":
				print(" ")
			case "ExpressionStatement":
				print(indent)
			case "Increment": print("")
			case "PrimaryIdentifier": print("")
			case "ReturnStatement":
				print(indent)
			case "UnaryExpression": print("")
			case "Unaryoperator": print("")
			default : println('''[node] «node»''')
		}
	}

	override tx_end(GNode node, List<Node> ancestors) {
		switch(node.name) {
			case "Conditional": {
				println('''«indent»#endif''');
				if(ancestors.last.name != "Conditional") println
				}
			default : print("")
		}
	}

	override tx_start(Node node, List<Node> ancestors) {
		println('''[node] «node»''')
	}

	override tx_end(Node node, List<Node> ancestors) {
	}

}

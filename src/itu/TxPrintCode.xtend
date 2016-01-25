package itu

import xtc.tree.GNode
import xtc.tree.Node
import xtc.lang.cpp.Syntax.Language
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import java.util.List
import xtc.lang.cpp.CTag

class TxPrintCode implements Tx {
	
	private var indent = ""
	
	override PresenceCondition tx_start(PresenceCondition condition, List<Node> ancestors) {
		if(ancestors.last.head == condition)
			println('''«indent»#if «condition»''')
		else
			println('''«indent»#elif «condition»''')
		condition
	}

	override void tx_end(PresenceCondition condition, List<Node> ancestors) {
		
	}

	override Language<CTag> tx_start(Language<CTag> language, List<Node> ancestors) {
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
		language
	}

	override void tx_end(Language<CTag> language, List<Node> ancestors) {
		
	}

	override GNode tx_start(GNode node, List<Node> ancestors) {
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
		node
	}

	override void tx_end(GNode node, List<Node> ancestors) {
		switch(node.name) {
			case "Conditional": {
				println('''«indent»#endif''');
				if(ancestors.last.name != "Conditional") println
				}
			default : print("")
		}
	}

	override Node tx_start(Node node, List<Node> ancestors) {
		println('''[node] «node»''')
		node
	}

	override void tx_end(Node node, List<Node> ancestors) {
		
	}

}

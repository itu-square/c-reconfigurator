package itu

import java.io.PrintStream
import java.util.List
import xtc.lang.cpp.CTag
import xtc.lang.cpp.PresenceConditionManager
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.tree.GNode
import xtc.tree.Node

class TxPrintCode extends Tx {
	
	private var indent = ""
	
	private val PrintStream output
	
	new(PresenceConditionManager manager, PrintStream output) {
		super(manager)
		this.output = output
	}
	
	override PresenceCondition tx_start(PresenceCondition condition, List<Node> ancestors) {
		if(ancestors.last.head == condition)
			output.println('''«indent»#if «condition»''')
		else
			output.println('''«indent»#elif «condition»''')
		manager.newPresenceCondition(condition.BDD)
	}

	override void tx_end(PresenceCondition condition, List<Node> ancestors) {
		
	}

	override Language<CTag> tx_start(Language<CTag> language, List<Node> ancestors) {
		switch (language.toString) {
			case ";":		output.println(language)
			case "{":		{ output.println(language); indent += "  " }
			case "}":		{ indent = indent.substring(2); output.println(language) }
			case ")": {
					output.print(language)
					if (ancestors.last.name == "SelectionStatement") output.println
			}		
			case "else":	output.println(indent + language)
			case "return": {
				output.print(indent + language)
				if (ancestors.last.length > 2) output.print(" ")
			}
			default: output.print(language)
		}
		language.copy
	}

	override void tx_end(Language<CTag> language, List<Node> ancestors) {
		
	}

	override GNode tx_start(GNode node, List<Node> ancestors) {
		switch(node.name) {
			case "Declaration":						output.print(indent)
			case "ExpressionStatement":				output.print(indent)
			case "ReturnStatement":					output.print(indent)
			case "SelectionStatement":				output.print(indent)
			case "SimpleDeclarator":				output.print(" ")
			case "InitializerOpt":					output.print(" ")
			case "Initializer":						output.print(" ")
			
			case "TranslationUnit":					output.print("")
			case "ExternalDeclarationList":			output.print("")
			case "Conditional":						output.print("")
			case "DeclaringList":					output.print("")
			case "FunctionDeclarator":				output.print("")
			case "PostfixingFunctionDeclarator":	output.print("")
			case "FunctionDefinition":				output.print("")
			case "FunctionPrototype":				output.print("")
			case "CompoundStatement":				output.print("")
			case "DeclarationOrStatementList":		output.print("")
			case "Increment":						output.print("")
			case "PrimaryIdentifier":				output.print("")
			case "UnaryExpression":					output.print("")
			case "Unaryoperator":					output.print("")
			default : output.println(node)
		}
		
		val newNode = GNode::create(node.name)
		node.forEach[newNode.add(it)]
		newNode
	}

	override void tx_end(GNode node, List<Node> ancestors) {
		switch(node.name) {
			case "Conditional": {
				output.println('''«indent»#endif''');
				if(ancestors.last.name != "Conditional") output.println
				}
			default : output.print("")
		}
	}

	override Node tx_start(Node node, List<Node> ancestors) {
		output.println('''[node] «node»''')
		val newNode = GNode::create(node.name)
		node.forEach[newNode.add(it)]
		newNode
	}

	override void tx_end(Node node, List<Node> ancestors) {
		
	}

}

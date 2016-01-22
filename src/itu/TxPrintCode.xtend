package itu

import xtc.tree.GNode
import xtc.tree.Node
import xtc.lang.cpp.PresenceConditionManager$PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.lang.cpp.PresenceConditionManager
import java.util.List

class TxPrintCode implements Tx {
	
	override tx_start(PresenceConditionManager.PresenceCondition condition, List<Node> ancestors) {
	}

	override tx_end(PresenceConditionManager.PresenceCondition condition, List<Node> ancestors) {
	}

	override tx_start(Language language, List<Node> ancestors) {
	}

	override tx_end(Language language, List<Node> ancestors) {
	}

	override tx_start(GNode node, List<Node> ancestors) {
		// case "TranslationUnit": {
		// println('''«ind(indentLevel)» «node.name» (class: «node.class.name»)''');
		// node.forEach[n | TxPrint::tx(n, indentLevel+1)]
		// }
		// case "ExternalDeclarationList": {
		// println('''«ind(indentLevel)» «node.name» (class: «node.class.name»)''');
		// node.forEach[n | TxPrint::tx(n, indentLevel+1)]
		// }
		// node.forEach[n | TxPrint::tx(n, indentLevel+1)]
		// case "Declaration": {
		// println('''«ind(indentLevel)» «node.name» (class: «node.class.name»)''');
		// node.forEach[n | TxPrint::tx(n, indentLevel+1)]
		// }
		// case "DeclaringList": {
		// println('''«ind(indentLevel)» «node.name» (class: «node.class.name»)''');
		// node.forEach[n | TxPrint::tx(n, indentLevel+1)]
		// }
		// case "FunctionDefinition": {
		// println('''«ind(indentLevel)» «node.name» (class: «node.class.name»)''');
		// node.forEach[n | TxPrint::tx(n, indentLevel+1)]
		// }
		// case "FunctionDeclarator": {
		// println('''«ind(indentLevel)» «node.name» (class: «node.class.name»)''');
		// node.forEach[n | TxPrint::tx(n, indentLevel+1)]
		// }
		// case "FunctionPrototype": {
		// println('''«ind(indentLevel)» «node.name» (class: «node.class.name»)''');
		// node.forEach[n | TxPrint::tx(n, indentLevel+1)]
		// }
		// case "CompoundStatement": {
		// println('''«ind(indentLevel)» «node.name» (class: «node.class.name»)''');
		// node.forEach[n | TxPrint::tx(n, indentLevel+1)]
		// }
		// case "SimpleDeclarator": {
		// println('''«ind(indentLevel)» «node.name» (class: «node.class.name»)''');
		// node.forEach[n | TxPrint::tx(n, indentLevel+1)]
		// }
		// case "DeclarationOrStatementList": {
		// println('''«ind(indentLevel)» «node.name» (class: «node.class.name»)''');
		// node.forEach[n | TxPrint::tx(n, indentLevel+1)]
		// }
		// case "ReturnStatement": {
		// println('''«ind(indentLevel)» «node.name» (class: «node.class.name»)''');
		// node.forEach[n | TxPrint::tx(n, indentLevel+1)]
		// }
		// case "UnaryExpression": {
		// println('''«ind(indentLevel)» «node.name» (class: «node.class.name»)''');
		// node.forEach[n | TxPrint::tx(n, indentLevel+1)]
		// }
		// case "Unaryoperator": {
		// println('''«ind(indentLevel)» «node.name» (class: «node.class.name»)''');
		// node.forEach[n | TxPrint::tx(n, indentLevel+1)]
		// }
	}

	override tx_end(GNode node, List<Node> ancestors) {
	}

	override tx_start(Node node, List<Node> ancestors) {
	}

	override tx_end(Node node, List<Node> ancestors) {
	}

}

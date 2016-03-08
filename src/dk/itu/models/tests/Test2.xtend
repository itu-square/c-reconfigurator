package dk.itu.models.tests

import xtc.tree.Node
import dk.itu.models.strategies.BottomUpStrategy
import dk.itu.models.rules.RemOneRule
import dk.itu.models.rules.RemExtraRule
import dk.itu.models.rules.SplitConditionalRule
import dk.itu.models.rules.ConditionPushDownRule

class Test2 extends Test {

	new(String inputFile) {
		super(inputFile)
	}

	override transform(Node node) {
//		println(file)
//		writeToFile(node.printCode, file)
//		writeToFile(node.printAST, folder + "out.ast")

//		val bus = new BottomUpStrategy()
//		bus.register(new RemOneRule)
//		bus.register(new RemExtraRule)
//		bus.register(new SplitConditionalRule)
//		bus.register(new ConditionPushDownRule)
//
//		var Node normalized = bus.transform(node) as Node
//		writeToFile(normalized.printCode, file)
	}

}
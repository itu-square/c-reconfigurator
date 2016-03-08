package dk.itu.models.tests

import xtc.tree.Node
import dk.itu.models.strategies.BottomUpStrategy
import dk.itu.models.rules.RemOneRule
import dk.itu.models.rules.RemExtraRule
import dk.itu.models.rules.SplitConditionalRule
import dk.itu.models.rules.ConditionPushDownRule
import dk.itu.models.strategies.TopDownStrategy
import dk.itu.models.rules.ReconfigureFunctionRule

class Test2 extends Test {

	new(String inputFile) {
		super(inputFile)
	}

	override transform(Node node) {
//		println(file)
		writeToFile(node.printCode, file)
		writeToFile(node.printAST, file + ".ast")

		val bus = new BottomUpStrategy()
		bus.register(new RemOneRule)
		bus.register(new RemExtraRule)
		bus.register(new SplitConditionalRule)
		bus.register(new ConditionPushDownRule)

		var Node normalized = bus.transform(node) as Node
		writeToFile(normalized.printCode, file)
		
		//println("PHASE 2 - Extract functions")

		val tdn = new TopDownStrategy
		val extfRule = new ReconfigureFunctionRule
		tdn.register(extfRule)

		var Node funextracted = tdn.transform(normalized) as Node
		writeToFile(funextracted.printCode, file)
	}

}
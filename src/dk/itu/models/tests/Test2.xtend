package dk.itu.models.tests

import xtc.tree.Node
import dk.itu.models.strategies.BottomUpStrategy
import dk.itu.models.rules.RemOneRule
import dk.itu.models.rules.RemExtraRule
import dk.itu.models.rules.SplitConditionalRule
import dk.itu.models.rules.ConditionPushDownRule
import dk.itu.models.strategies.TopDownStrategy
import dk.itu.models.rules.ReconfigureFunctionRule
import dk.itu.models.rules.RemSequentialMutexConditionalRule
import dk.itu.models.rules.RemNestedMutexConditionalRule
import dk.itu.models.rules.ReconfigureVariableRule
import dk.itu.models.rules.Ifdef2IfRule
import dk.itu.models.Reconfigurator

class Test2 extends Test {

	new(String inputFile) {
		super(inputFile)
	}

	override transform(Node node) {
//		println(file)
		writeToFile(node.printCode, file + "base.c")
//		writeToFile(node.printAST, file + ".ast")

		val bus = new BottomUpStrategy()
		bus.register(new RemOneRule)
		bus.register(new RemExtraRule)
		bus.register(new RemSequentialMutexConditionalRule)
		bus.register(new RemNestedMutexConditionalRule)
		bus.register(new SplitConditionalRule)
		bus.register(new ConditionPushDownRule)

		var Node normalized = bus.transform(node) as Node
		writeToFile(normalized.printCode, file + "norm.c")
		
		//println("PHASE 2 - Extract functions")

		val tdn = new TopDownStrategy
		val extfRule = new ReconfigureFunctionRule
		tdn.register(extfRule)

		var Node funextracted = tdn.transform(normalized) as Node
		writeToFile(funextracted.printCode, file)
		
		//println("PHASE 3 - Extract variables")

		val extVarRule = new ReconfigureVariableRule
		tdn.register(extVarRule)

		var Node varextracted = tdn.transform(funextracted) as Node
		writeToFile(varextracted.printCode, file + "var.c")
		writeToFile(varextracted.printAST, file + "var.ast")
		
		//println("PHASE 4 - Turn the rest ifdefs to ifs")
		
		val ifdef2ifRule = new Ifdef2IfRule
		tdn.register(ifdef2ifRule)
		var Node ifdefextracted = tdn.transform(varextracted) as Node
		writeToFile(ifdefextracted.printCode, file)
		writeToFile(ifdefextracted.printAST, file + ".ast")
		
	}

}